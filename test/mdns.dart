import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:signale/signale.dart';

class MDnsServicePublisher {
  RawDatagramSocket? _socket;
  final String _serviceName;
  final String _serviceType;
  final int _port;
  final Map<String, String> _txtRecords;
  final String _instanceName;

  Timer? _advertisementTimer;
  bool _isRunning = false;

  static InternetAddress MDNS_IPv4_ADDRESS = InternetAddress('224.0.0.251');
  static const int MDNS_PORT = 5353;

  /// 创建mDNS服务发布器
  ///
  /// [instanceName] 服务实例名称，例如"MyDevice"
  /// [serviceType] 服务类型，例如"_adb-tls-pairing._tcp"
  /// [port] 服务端口号
  /// [txtRecords] 可选的TXT记录
  MDnsServicePublisher({
    required String instanceName,
    required String serviceType,
    required int port,
    Map<String, String> txtRecords = const {},
  })  : _instanceName = instanceName,
        _serviceType = serviceType,
        _serviceName = '$instanceName.$serviceType.local',
        _port = port,
        _txtRecords = txtRecords;

  /// 启动服务发布
  Future<void> start() async {
    if (_isRunning) return;

    try {
      // 找到合适的网络接口
      List<NetworkInterface> interfaces = await NetworkInterface.list(
        includeLinkLocal: true,
        type: InternetAddressType.IPv4,
      );

      if (interfaces.isEmpty) {
        Log.e('未找到可用的网络接口');
        return;
      }

      // 选择第一个非回环接口
      NetworkInterface? selectedInterface;
      for (var interface in interfaces) {
        if (!interface.name.startsWith('lo')) {
          selectedInterface = interface;
          break;
        }
      }

      if (selectedInterface == null) {
        selectedInterface = interfaces.first; // 退而求其次用任何接口
      }

      // 绑定到任何地址
      _socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        MDNS_PORT,
        reuseAddress: true,
        reusePort: true,
        ttl: 255,
      );

      // 加入多播组
      _socket!.joinMulticast(MDNS_IPv4_ADDRESS, selectedInterface);
      // _socket.multicastLoopback = true;
      // _socket!.setOption(SocketOption.ipMulticastLoop, true);
      _socket!.listen(_handleSocketEvent);

      // 定期发布服务公告
      _advertisementTimer = Timer.periodic(Duration(seconds: 60), (_) {
        _announceService();
      });

      // 立即发布一次
      _announceService();

      _isRunning = true;
      Log.i('mDNS服务发布器已启动: $_serviceName 在端口 $_port');
    } catch (e) {
      Log.e('启动mDNS发布器失败: $e');
      stop();
    }
  }

  /// 停止服务发布
  void stop() {
    _advertisementTimer?.cancel();
    _advertisementTimer = null;

    if (_socket != null) {
      try {
        _socket!.close();
      } catch (e) {
        // 忽略关闭错误
      }
      _socket = null;
    }

    _isRunning = false;
    Log.i('mDNS服务发布器已停止: $_serviceName');
  }

  /// 处理套接字事件
  void _handleSocketEvent(RawSocketEvent event) {
    if (event == RawSocketEvent.read && _socket != null) {
      final datagram = _socket!.receive();
      if (datagram != null) {
        // 解析mDNS查询并回复
        _handleQuery(datagram);
      }
    }
  }

  /// 处理接收到的查询
  void _handleQuery(Datagram datagram) {
    // 这里需要解析DNS查询包，这是个比较复杂的任务
    // 简单实现：检查是否有人在查询我们的服务
    // 如果是，则发送响应包

    // 注意：完整的实现需要解析DNS包结构，
    // 这里只作为示例，实际应用中可能需要更复杂的DNS包解析逻辑
    _announceService();
  }

  /// 发布服务公告
  void _announceService() {
    if (_socket == null) return;

    try {
      // 构建DNS响应包
      final packet = _buildServiceAnnouncementPacket();

      // 发送到mDNS多播地址
      final sent = _socket!.send(packet, MDNS_IPv4_ADDRESS, MDNS_PORT);

      if (sent > 0) {
        Log.i('已发送mDNS服务公告: $_serviceName');
      } else {
        Log.w('mDNS服务公告发送失败');
      }
    } catch (e) {
      Log.e('发送mDNS公告时出错: $e');
    }
  }

  /// 构建DNS响应包
  Uint8List _buildServiceAnnouncementPacket() {
    // 这里需要按照DNS包格式构建二进制数据
    // DNS包格式非常复杂，完整实现需要详细了解DNS协议

    // 以下是一个非常简化的示例框架
    // 实际应用中需要替换为真正的DNS包构建逻辑

    // 包含以下记录:
    // 1. PTR记录 - 指向服务实例
    // 2. SRV记录 - 包含主机名和端口
    // 3. TXT记录 - 包含额外属性
    // 4. A记录   - 包含IPv4地址

    // 此处省略实际的DNS包构建代码
    // 实现需要按照RFC 6762和RFC 1035规范构建DNS包

    // 为简单起见，这里返回一个空的数据包
    // 实际应用中，这里需要实现完整的DNS响应包构建
    return Uint8List(64);
  }
}
