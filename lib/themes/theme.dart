import 'package:flutter/material.dart';

const seed = Colors.indigo;

extension ThemeExt on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}

extension ThemeStateExt on State {
  ColorScheme get colorScheme => Theme.of(context).colorScheme;
}
