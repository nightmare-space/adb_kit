import 'package:adb_kit/app/controller/devices_controller.dart';
import 'package:adb_kit/global/instance/global.dart';
import 'package:adb_kit/utils/plugin_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xterm/xterm.dart';

class OTGTerminal extends StatefulWidget {
  const OTGTerminal({Key? key}) : super(key: key);

  @override
  State createState() => _OTGTerminalState();
}

class _OTGTerminalState extends State<OTGTerminal> {
  DevicesController controller = Get.find();
  Terminal terminal = Terminal();
  @override
  void initState() {
    super.initState();
    Global().otgTerminal.onOutput = (data) {
      PluginUtil.writeToOTG(data);
    };
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: TerminalView(
        Global().otgTerminal,
      ),
    );
  }
}
