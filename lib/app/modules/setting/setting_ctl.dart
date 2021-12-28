import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/config/settings.dart';
import 'package:flutter/material.dart';
import 'package:settings/settings.dart';

class SettingController {
  Future<void> changeServerPath(BuildContext context) async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset =
        renderBox.localToGlobal(renderBox.size.center(Offset.zero));
    final List<PopupMenuEntry<String>> items = <PopupMenuEntry<String>>[];
    for (final String path in <String>[
      Config.adbLocalPath,
      Config.sdcard,
    ]) {
      items.add(PopupMenuItem<String>(
        value: path,
        child: Text(path),
      ));
    }
    final String newPartition = await showMenu<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      position: RelativeRect.fromLTRB(offset.dx - offset.dx / 2, offset.dy,
          MediaQuery.of(context).size.width, 0.0),
      items: items,
      elevation: 0,
    );
    if (newPartition != null) {
      Settings.serverPath.set = newPartition;
    }
  }
}
