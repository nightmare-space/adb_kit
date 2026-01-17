import 'dart:async';
import 'dart:math';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:signale/signale.dart';

String _tag = 'MDNSDiscovery';
String generateRandomString(int length) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890\$';
  final random = Random();
  return String.fromCharCodes(List.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
}

class PairInfo {
  final String serviceId;
  final String password;
  PairInfo(this.serviceId, this.password);

  String content() {
    return 'WIFI:T:ADB;S:$serviceId;P:$password;;';
  }
}

PairInfo generatePairInfo() {
  final serviceId = 'studio-${generateRandomString(8)}';
  final password = generateRandomString(8);
  return PairInfo(serviceId, password);
}

const String pairServiceName = '_adb-tls-pairing._tcp';
const String connectServiceName = '_adb-tls-connect._tcp';

typedef DeviceCallback = void Function((String address, int port) device);

/// 静态 MDNS 设备发现类
/// - 使用 `MdnsDeviceDiscovery.addListener(serviceName, callback)` 注册监听
/// - 使用 `MdnsDeviceDiscovery.removeListener(serviceName, callback)` 注销监听
/// - 提供 `addPairListener` / `removePairListener` 与 `addConnectListener` / `removeConnectListener` 便捷方法
/// - 内部管理 `MDnsClient`、定时器与扫描任务；当没有监听时会停止客户端
class MdnsDeviceDiscovery {
  MdnsDeviceDiscovery._();
  static Logger log = Logger();
  static bool _enableLogging = false;
  static void enableLogging(bool enable) {
    _enableLogging = enable;
    log.level = enable ? LogLevel.debug : LogLevel.warning;
  }

  static final Map<String, Set<DeviceCallback>> _listeners = {};
  static final Map<String, MDnsClient> _clients = {};
  static final Map<String, Timer> _timers = {};

  static void addListener(String serviceName, DeviceCallback cb) {
    final set = _listeners.putIfAbsent(serviceName, () => <DeviceCallback>{});
    final added = set.add(cb);
    if (added) {
      if (_enableLogging) Log.i('Listener added for $serviceName. Total: ${set.length}', _tag);
      if (!_clients.containsKey(serviceName)) {
        _start(serviceName);
      }
    }
  }

  static void removeListener(String serviceName, DeviceCallback cb) {
    final set = _listeners[serviceName];
    if (set == null) return;
    set.remove(cb);
    if (_enableLogging) Log.i('Listener removed for $serviceName. Remaining: ${set.length}');
    if (set.isEmpty) {
      _stop(serviceName);
    }
  }

  static void addPairListener(DeviceCallback cb) => addListener(pairServiceName, cb);
  static void removePairListener(DeviceCallback cb) => removeListener(pairServiceName, cb);
  static void addConnectListener(DeviceCallback cb) => addListener(connectServiceName, cb);
  static void removeConnectListener(DeviceCallback cb) => removeListener(connectServiceName, cb);

  static Future<void> _start(String name) async {
    try {
      final client = MDnsClient();
      await client.start();
      _clients[name] = client;

      _timers[name]?.cancel();
      _timers[name] = Timer.periodic(Duration(milliseconds: 1200), (_) async {
        _scanOnce(name);
      });
      if (_enableLogging) Log.i('MDNS discovery started for $name', _tag);
    } catch (e, st) {
      if (_enableLogging) Log.e('Failed to start MDNS client for $name: $e\n$st', _tag);
    }
  }

  static Future<void> _stop(String name) async {
    try {
      _timers[name]?.cancel();
      _timers.remove(name);
      final client = _clients.remove(name);
      if (client != null) {
        client.stop();
        if (_enableLogging) Log.i('MDNS stopped for $name', _tag);
      }
      _listeners.remove(name);
    } catch (e, st) {
      if (_enableLogging) Log.e('Error stopping MDNS client for $name: $e\n$st', _tag);
    }
  }

  static Future<void> _scanOnce(String name) async {
    if (_enableLogging) Log.w('Scanning for $name invoke', _tag);
    final client = _clients[name];
    if (client == null) return;
    try {
      final ptrSw = Stopwatch()..start();
      // adb pair 广播的时间应该是 1000
      // TODO: iOS 有异常
      Stream<PtrResourceRecord> ptrs = client.lookup(ResourceRecordQuery.serverPointer(name), timeout: Duration(milliseconds: 1200));
      await for (PtrResourceRecord ptr in ptrs) {
        if (_enableLogging) Log.i('ptr : $ptr', _tag);
        final ptrSw = Stopwatch()..start();
        await for (final SrvResourceRecord srv in client.lookup<SrvResourceRecord>(ResourceRecordQuery.service(ptr.domainName))) {
          final String bundleId = ptr.domainName;
          if (_enableLogging) Log.i('${srv.target}:${srv.port} priority:${srv.priority} weight:${srv.weight} for "$bundleId".');

          final ptrSw = Stopwatch()..start();
          // IPv4
          await for (final IPAddressResourceRecord ip in client.lookup(
            ResourceRecordQuery.addressIPv4(srv.target),
            timeout: Duration(milliseconds: 100),
          )) {
            if (_enableLogging) Log.i('- IPv4: ${ip.address.address}', _tag);
            final listeners = _listeners[name];
            if (listeners != null) {
              // 使用一个 snapshot 避免在回调中改变集合导致并发问题
              for (final cb in Set<DeviceCallback>.from(listeners)) {
                try {
                  cb((ip.address.address, srv.port));
                } catch (e, st) {
                  if (_enableLogging) Log.e('Listener error: $e\n$st', _tag);
                }
              }
            }
          }
          // calculate elapsed time for debugging
          final elapsed = ptrSw.elapsedMilliseconds;
          if (_enableLogging) Log.i('Resolved ${srv.target} IPv4 in ${elapsed}ms', _tag);
          ptrSw.reset();
          // IPv6
          await for (final IPAddressResourceRecord ip in client.lookup(
            ResourceRecordQuery.addressIPv6(srv.target),
            timeout: Duration(milliseconds: 100),
          )) {
            if (_enableLogging) Log.i('- IPv6: ${ip.address.address}', _tag);
          }
          // calculate elapsed time for debugging
          final elapsed6 = ptrSw.elapsedMilliseconds;
          if (_enableLogging) Log.i('Resolved ${srv.target} IPv6 in ${elapsed6}ms', _tag);
        }
        // calculate elapsed time for debugging
        final srvElapsed = ptrSw.elapsedMilliseconds;
        if (_enableLogging) Log.i('Resolved SRV for ${ptr.domainName} in ${srvElapsed}ms', _tag);
        ptrSw.stop();
      }
      final totalElapsed = ptrSw.elapsedMilliseconds;
      if (_enableLogging) Log.e('MDNS scan for $name completed in ${totalElapsed}ms', _tag);
    } catch (e, st) {
      if (_enableLogging) Log.e('Error scanning $name: $e\n$st', _tag);
    }
  }

  /// 停止所有正在运行的发现
  static Future<void> stopAll() async {
    final keys = List<String>.from(_clients.keys);
    for (final k in keys) {
      await _stop(k);
    }
  }
}
