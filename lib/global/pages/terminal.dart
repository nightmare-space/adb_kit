import 'dart:io';

import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/app/modules/overview/pages/overview_page.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/global/widget/item_header.dart';
import 'package:adbutil/adbutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:termare_pty/termare_pty.dart';

class TerminalPage extends StatelessWidget {
  const TerminalPage({Key key, this.enableInput = false}) : super(key: key);

  final bool enableInput;

  @override
  Widget build(BuildContext context) {
    return TermarePty(
      enableInput: enableInput,
      controller: Global.instance.termareController..enableCursor(),
      pseudoTerminal: Global.instance.pseudoTerminal,
    );
    
  }
}
