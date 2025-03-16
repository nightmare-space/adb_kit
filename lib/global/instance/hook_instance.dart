class HookInstance {
  static final HookInstance _instance = HookInstance._internal();

  factory HookInstance() {
    return _instance;
  }

  HookInstance._internal();

  void init() {
    print('HookInstance init');
  }
}
