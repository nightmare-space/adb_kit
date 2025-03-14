import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:signale/signale.dart';

import 'adb_foundation.dart';

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

Future<Timer> listenConnectDeivce(DeviceCallback onFind) async {
  return listenDevice(onFind, connectServiceName);
}

Future<Timer> listenPairDeivce(DeviceCallback onFind) async {
  return listenDevice(onFind, pairServiceName);
}

Future<Timer> listenDevice(
  DeviceCallback onFind,
  String name,
) async {
  final MDnsClient client = MDnsClient();
  await client.start();
  Timer timer = Timer.periodic(Duration(milliseconds: 100), (timer) async {
    Stream stream = client.lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(name));
    await for (PtrResourceRecord ptr in stream) {
      // Use the domainName from the PTR record to get the SRV record,
      // which will have the port and local hostname.
      // Note that duplicate messages may come through, especially if any
      // other mDNS queries are running elsewhere on the machine.
      Log.i('ptr : $ptr');
      await for (final SrvResourceRecord srv in client.lookup<SrvResourceRecord>(ResourceRecordQuery.service(ptr.domainName))) {
        // Domain name will be something like "io.flutter.example@some-iphone.local._dartobservatory._tcp.local"
        final String bundleId = ptr.domainName; //.substring(0, ptr.domainName.indexOf('@'));
        Log.i('${srv.target}:${srv.port} for "$bundleId".');
        // 添加查询 IP 地址的代码
        await for (final IPAddressResourceRecord ip in client.lookup<IPAddressResourceRecord>(
          ResourceRecordQuery.addressIPv4(srv.target),
        )) {
          Log.i('IPv4 地址: ${ip.address.address}');
          onFind((ip.address.address, srv.port));
          timer.cancel();
        }

        // 如需要 IPv6 地址
        await for (final IPAddressResourceRecord ip in client.lookup<IPAddressResourceRecord>(
          ResourceRecordQuery.addressIPv6(srv.target),
        )) {
          Log.i('IPv6 地址: ${ip.address.address}');
        }
      }
    }
  });
  return timer;
}
