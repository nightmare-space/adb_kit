class ScreenSize {
  ScreenSize();
  //Physical size: 1600x2560
  factory ScreenSize.fromWM(String data) {
    ScreenSize size = ScreenSize();
    String tmp = data.replaceAll(RegExp('.*: '), '');
    size.width = int.tryParse(tmp.split('x').first);
    size.height = int.tryParse(tmp.split('x')[1]);
    return size;
  }
  int width;
  int height;
  double get radio => width / height;
}
