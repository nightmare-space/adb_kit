import 'dart:ui';

const int opacity01 = 26;
const int opacity008 = 20;
const int opacity011 = 28;
const int opacity012 = 31;
const int opacity013 = 33;
const int opacity014 = 36;
const int opacity015 = 38;
// const int opacity016 = 41;
// const int opacity017 = 43;
// const int opacity018 = 46;
// const int opacity019 = 48;
const int opacity02 = 51;
const int opacity03 = 77;
const int opacity04 = 102;
const int opacity05 = 128;
const int opacity06 = 153;
const int opacity07 = 179;
const int opacity08 = 204;
const int opacity09 = 230;
const int opacity10 = 255;

extension ColorExt on Color {
  Color o(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    return withAlpha((255.0 * opacity).round());
  }
}
