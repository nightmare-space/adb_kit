import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/global/pages/terminal.dart';
import 'package:dart_pty/dart_pty.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:termare_pty/termare_pty.dart';

class ExecCmdPage extends StatefulWidget {
  @override
  _ExecCmdPageState createState() => _ExecCmdPageState();
}

class _ExecCmdPageState extends State<ExecCmdPage> {
  TextEditingController editingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  Future<void> execCmd() async {
    // Provider.of<ProcessState>(context).clear();
    // final String cmd = editingController.text;
    // final String result = await exec('echo $cmd\n$cmd');
    // Provider.of<ProcessState>(context).appendOut(result);

    // Provider.of<ProcessState>(context).clear();
    Global.instance.pseudoTerminal.write(editingController.text + '\n');
    // NiProcess.exec(
    //   editingController.text,
    //   getStderr: true,
    //   callback: (output) {
    //     print('ss======>$output');

    //     if (output.trim() == 'process_exit') {
    //       return;
    //     }
    //     output = output.replaceAll('process_exit', '');
    //     Provider.of<ProcessState>(context).appendOut(output);
    //   },
    // );
    editingController.clear();
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar;
    if (kIsWeb || MediaQuery.of(context).orientation == Orientation.portrait) {
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
      // backgroundColor: Colors.white,
      appBar: appBar,
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: Dimens.gap_dp8,
          horizontal: Dimens.gap_dp8,
        ),
        child: Column(
          children: [
            const Expanded(
              child: TerminalPage(
                enableInput: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
