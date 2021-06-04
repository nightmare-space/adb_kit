import 'dart:async';
import 'dart:io'
    show RawDatagramSocket, RawSocketEvent, InternetAddress, Datagram;
import 'dart:convert' show utf8;
import 'dart:async' show Timer;

main() {
  RawDatagramSocket dsocket;
  RawDatagramSocket.bind(InternetAddress.anyIPv4, 0).then((datagramSocket) {
    dsocket = datagramSocket;
    datagramSocket.broadcastEnabled = true;
    datagramSocket.readEventsEnabled = true;
    datagramSocket.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        Datagram datagram = datagramSocket.receive();
        if (datagram != null) {
          print(
              '${datagram.address}:${datagram.port} -- ${utf8.decode(datagram.data)}');
          //datagramSocket.close();
        }
      }
    });
  });
  Timer.periodic(Duration(seconds: 1), (timer) {
    if (timer.isActive) {
      dsocket.send(
          "io.app.service".codeUnits, InternetAddress("224.0.0.1"), 8000);
    }
  });
}
