class ADBConnectResult {
  final String message;

  ADBConnectResult(this.message);

  @override
  String toString() {
    return message;
  }
}

class SuccessConnect extends ADBConnectResult {
  SuccessConnect() : super('success connect');
}

class SuccessPair extends ADBConnectResult {
  SuccessPair() : super('success pair');
}
