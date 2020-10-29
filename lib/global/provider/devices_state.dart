import 'package:flutter/material.dart';
// 仅仅用于MaterialApp上的更新

class DevicesState extends ChangeNotifier {
  void hasChanged() {
    notifyListeners();
  }
}
