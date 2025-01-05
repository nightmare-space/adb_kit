import 'dart:io';

void main() {
  String ip = '192.168.31.124';
  int startPort = 1;
  int endPort = 65535;

  scanPorts(ip, startPort, endPort);
}

void scanPorts(String ip, int startPort, int endPort) async {
  List<int> ports = [];
  for (int port = startPort; port <= endPort; port++) {
    print('Scanning port $port');
    try {
      Socket socket = await Socket.connect(ip, port, timeout: Duration(milliseconds: 100));
      // print('Port $port is open');
      ports.add(port);
      socket.destroy();
    } catch (e) {
      // Port is closed or unreachable
    }
  }
  print('Open ports: $ports');
}
