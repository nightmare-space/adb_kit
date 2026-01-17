class AlreadyConnected extends AdbException {
  AlreadyConnected() : super('this device is already connected');
}

class ConnectRefused extends AdbException {
  ConnectRefused() : super('connect refused');
}

class NeedAuthenticate extends AdbException {
  NeedAuthenticate() : super('need authenticate');
}

class AdbException implements Exception {
  final String message;
  AdbException(this.message);

  @override
  String toString() => message;
}
