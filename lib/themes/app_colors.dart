import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class AppColors {
  AppColors._();
  static const MaterialColor grey = Colors.grey;
  static const Color fontColor = Color(0xff201b1a);
  static const Color inputBorderColor = Color(0xffebebed);
  static Color fontTitle = const Color(0xff0d0d14);
  static Color fontDetail = const Color(0xff707076);
  static const Color background = Color(0xfff5f5f7);
  // static Color accent = const Color(0xff3573e0);
  static const Color accent = CandyColors.indigo;
  static Color contentBorder = const Color(0xffebebed);
  static Color terminalBack = const Color(0xffebebed);

  static const Color borderColor = Color(0xffeeeeee);
  static const Color surface = Color(0xfff5f5f7);
}

const MaterialColor _grey = MaterialColor(
  _greyPrimaryValue,
  <int, Color>{
    // 对应UI的灰度4
    100: Color(0xFFf1f1f1),
    // 对应UI的灰度3
    200: Color(0xFFe1e1e1),
    // 对应UI的灰度2
    500: Color(_greyPrimaryValue),
    // 对应UI的灰度1
    900: Color(0x00000000),
  },
);
const int _greyPrimaryValue = 0xFF9999999;
