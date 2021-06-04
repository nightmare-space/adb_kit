import 'dart:io'
    show RawDatagramSocket, RawSocketEvent, InternetAddress, Datagram;
import 'dart:convert' show utf8;

main() => RawDatagramSocket.bind(InternetAddress.anyIPv4, 8000)
        .then((datagramSocket) {
      datagramSocket.readEventsEnabled = true;
      datagramSocket.joinMulticast(InternetAddress("224.0.0.1"));
      datagramSocket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram datagram = datagramSocket.receive();
          if ((datagram != null) &&
              (utf8.decode(datagram.data) == "io.app.service")) {
            datagramSocket.send(datagram.data, datagram.address, datagram.port);
            print(
                '${datagram.address}:${datagram.port} -- ${utf8.decode(datagram.data)}');
          }
        }
      });
    });
