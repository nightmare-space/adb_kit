class ADBException implements Exception {
  ADBException({this.message});

  final String? message;

  @override
  String toString() {
    return 'adb exception : $message';
  }
}

class AlreadyConnect extends ADBException {
  AlreadyConnect(String message) : super(message: message);
}

class ConnectFail extends ADBException {
  ConnectFail(String message) : super(message: message);
}
