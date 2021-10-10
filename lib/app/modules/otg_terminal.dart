import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:adb_tool/utils/plugin_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:termare_view/termare_view.dart';

class OTGTerminal extends StatefulWidget {
  const OTGTerminal({Key key}) : super(key: key);

  @override
  _OTGTerminalState createState() => _OTGTerminalState();
}

class _OTGTerminalState extends State<OTGTerminal> {
  DevicesController controller = Get.find();
  @override
  void initState() {
    super.initState();
  }

  // Future<void> loop() async {
  //   while (mounted) {
  //     Log.w('等待');
  //     final String data = await channel.invokeMethod('read');
  //     Log.w('data -> $data');
  //     _controller.write(data);
  //     await Future.delayed(const Duration(milliseconds: 600));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: TermareView(
        keyboardInput: (String data) {
          PluginUtil.writeToOTG(data);
        },
        controller: controller.otgTerm,
      ),
    );
  }
}
