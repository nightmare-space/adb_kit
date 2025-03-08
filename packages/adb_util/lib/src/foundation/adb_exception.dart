class AlreadyConnected extends ADBException {
  AlreadyConnected() : super('this device is already connected');
}

class ConnectRefused extends ADBException {
  ConnectRefused() : super('connect refused');
}

class NeedAuthenticate extends ADBException {
  NeedAuthenticate() : super('need authenticate');
}

class ADBException implements Exception {
  final String message;
  ADBException(this.message);

  @override
  String toString() => message;
}
