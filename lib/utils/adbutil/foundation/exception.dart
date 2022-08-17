class AdbException implements Exception {
  AdbException({this.message});

  final String message;

  @override
  String toString() {
    return 'adb exception : $message';
  }
}

class AlreadyConnect extends AdbException {
  AlreadyConnect(String message) : super(message: message);
}

class ConnectFail extends AdbException {
  ConnectFail(String message) : super(message: message);
}
