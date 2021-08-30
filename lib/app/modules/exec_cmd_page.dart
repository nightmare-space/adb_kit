import 'package:adb_tool/app/modules/overview/pages/overview_page.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/global/pages/terminal.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class ExecCmdPage extends StatefulWidget {
  @override
  _ExecCmdPageState createState() => _ExecCmdPageState();
}

class _ExecCmdPageState extends State<ExecCmdPage> {
  TextEditingController editingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  Future<void> execCmd() async {
    Global.instance.pseudoTerminal.write(editingController.text + '\n');

    editingController.clear();
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar;
    if (Responsive.of(context).screenType == ScreenType.phone) {
      appBar = AppBar(
        brightness: Brightness.light,
        title: const Text('执行命令'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      );
    }
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: Dimens.gap_dp8,
            horizontal: Dimens.gap_dp8,
          ),
          child: Column(
            children: const [
              Expanded(
                child: CardItem(
                  child: TerminalPage(
                    enableInput: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
