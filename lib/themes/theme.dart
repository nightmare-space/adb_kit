import 'package:flutter/material.dart';
export './theme_dark.dart';
export './theme_light.dart';

const seed = Colors.indigo;

extension ThemeExt on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}

extension ThemeStateExt on State {
  ColorScheme get colorScheme => Theme.of(context).colorScheme;
}
