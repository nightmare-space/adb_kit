import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/utils/plugin_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OTGTerminal extends StatefulWidget {
  const OTGTerminal({Key key}) : super(key: key);

  @override
  State createState() => _OTGTerminalState();
}

class _OTGTerminalState extends State<OTGTerminal> {
  DevicesController controller = Get.find();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // child: TermareView(
      //   keyboardInput: (String data) {
      //     PluginUtil.writeToOTG(data);
      //   },
      //   controller: controller.otgTerm,
      // ),
    );
  }
}
