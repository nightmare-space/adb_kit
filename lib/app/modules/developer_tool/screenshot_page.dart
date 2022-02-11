import 'dart:io';
import 'dart:typed_data';

import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adbutil/adbutil.dart';
import 'package:flutter/material.dart';

class ScreenshotPage extends StatefulWidget {
  const ScreenshotPage({Key key, this.devicesEntity}) : super(key: key);
  final DevicesEntity devicesEntity;

  @override
  _ScreenshotPageState createState() => _ScreenshotPageState();
}

class _ScreenshotPageState extends State<ScreenshotPage> {
  Uint8List byte = Uint8List.fromList([]);
  @override
  void initState() {
    super.initState();
    getScreen();
  }

  Future<void> getScreen() async {
    await asyncExec(
      'adb -s ${widget.devicesEntity.serial} shell screencap -p >/sdcard/tmp.png',
    );
    byte = await File('/sdcard/tmp.png').readAsBytes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        getScreen();
      },
      child: Image.memory(byte),
    );
  }
}
