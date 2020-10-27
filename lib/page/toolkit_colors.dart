import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class YanToolColors {
  static const Color accentColor = Color(0xff811016);
  static const Color appColor = Color(0xff811016);
  // static const Color appColor = Color(0xff4b5c76);
  static const Color fontsColor = Color(0xff4b5c76);
  static const List<Color> candyColor = <Color>[
    Color(0xffef92a5),
    Color(0xff73b3fa),
    Color(0xffb4d761),
    Color(0xffcc99fe),
    Color(0xff6d998e),
    Colors.deepPurple,
    Colors.indigo,
  ];
  static Color getRandomColor() {
    return candyColor[Random().nextInt(6)];
  }
}
