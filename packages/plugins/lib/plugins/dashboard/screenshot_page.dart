import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:adb_util/adb_util.dart';

class ScreenshotPage extends StatefulWidget {
  const ScreenshotPage({super.key, this.devicesEntity});
  final ADBDevice? devicesEntity;

  @override
  State createState() => _ScreenshotPageState();
}

class _ScreenshotPageState extends State<ScreenshotPage> {
  Uint8List byte = Uint8List.fromList([]);
  @override
  void initState() {
    super.initState();
    getScreen();
  }

  Future<void> getScreen() async {
    await exec(
      'adb -s ${widget.devicesEntity!.serial} shell screencap -p >/sdcard/tmp.png',
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
