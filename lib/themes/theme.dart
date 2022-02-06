export 'color_schema_extension.dart';
export 'default_theme_data.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:flutter/material.dart';

abstract class YanTheme {
  Color primaryColor;
  Color background;
  Color inputColor;
  Color cardColor;
  Color fontColor;
  MaterialColor grey;
}

class DarkTheme implements YanTheme {
  @override
  Color background = Colors.black;

  @override
  Color cardColor = Color(0xFF1a1a1a);

  @override
  Color inputColor = Color(0xFF212121);

  @override
  Color primaryColor = AppColors.accent;

  @override
  Color fontColor = Colors.white;

  ///    rather than hard-coding colors in your build methods.
  // static const MaterialColor grey = MaterialColor(
  //   _greyPrimaryValue,
  //   <int, Color>{
  //      50: Color(0xFFFAFAFA),
  //     100: Color(0xFFF5F5F5),
  //     200: Color(0xFFEEEEEE),
  //     300: Color(0xFFE0E0E0),
  //     350: Color(0xFFD6D6D6), // only for raised button while pressed in light theme
  //     400: Color(0xFFBDBDBD),
  //     500: Color(_greyPrimaryValue),
  //     600: Color(0xFF757575),
  //     700: Color(0xFF616161),
  //     800: Color(0xFF424242),
  //     850: Color(0xFF303030), // only for background color in dark theme
  //     900: Color(0xFF212121),
  //   },
  // );
  @override
  MaterialColor grey = const MaterialColor(
    0xff999999,
    <int, Color>{
      50: Color(0xFF0a0a0a),
      100: Color(0xff1a1a1a),
      200: Color(0xFF212121),
      300: Color(0xFF3d3d3d),
      400: Color(0xFF3a3a3a),
      900: Color(0x00000000),
    },
  );
}

class LightTheme implements YanTheme {
  @override
  Color background = const Color(0xfff5f5f7);

  @override
  Color cardColor = Colors.white;

  @override
  Color inputColor = Color(0xFFF5F5F5);

  @override
  Color primaryColor = AppColors.accent;

  @override
  Color fontColor = AppColors.fontColor;

  @override
  MaterialColor grey = const MaterialColor(
    0xff999999,
    <int, Color>{
      50: Color(0xFFFAFAFA),
      100: Color(0xFFF5F5F5),
      200: Color(0xFFEEEEEE),
      300: Color(0xFFE0E0E0),
      350: Color(0xFFD6D6D6),
      400: Color(0xFFBDBDBD),
      500: Color(0xff999999),
      600: Color(0xFF757575),
      700: Color(0xFF616161),
      800: Color(0xFF424242),
      850: Color(0xFF303030), // only for background color in dark theme
      900: Color(0xFF212121),
      //   },
    },
  );
}
