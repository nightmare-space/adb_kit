import 'dart:io';
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
  PseudoTerminal pseudoTerminal = PseudoTerminal(
    executable: 'sh',
    environment: PlatformUtil.environment(),
  );
  FocusNode focusNode = FocusNode();
  Future<void> execCmd() async {
    // Provider.of<ProcessState>(context).clear();
    // final String cmd = editingController.text;
    // final String result = await exec('echo $cmd\n$cmd');
    // Provider.of<ProcessState>(context).appendOut(result);

    // Provider.of<ProcessState>(context).clear();
    pseudoTerminal.write(editingController.text + '\n');
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
    if (!kIsWeb && Platform.isAndroid) {
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
      body: Column(
        children: [
          Expanded(
            child: TerminalPage(
              enableInput: true,
            ),
          ),
        ],
      ),
      // body: Stack(
      //   alignment: Alignment.topCenter,
      //   children: [
      //     Padding(
      //       padding: EdgeInsets.fromLTRB(
      //         Dimens.gap_dp8,
      //         Dimens.gap_dp8,
      //         Dimens.gap_dp8,
      //         Dimens.gap_dp8,
      //       ),
      //       child: Stack(
      //         children: [
      //           ConstrainedBox(
      //             constraints: BoxConstraints(
      //               maxHeight: MediaQuery.of(context).size.height -
      //                   kToolbarHeight -
      //                   Dimens.setWidth(140),
      //             ),
      //             // height: MediaQuery.of(context).size.height * 3 / 4,
      //             child: TermarePty(
      //               pseudoTerminal: pseudoTerminal,
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //     Align(
      //       alignment: Alignment.bottomCenter,
      //       child: SingleChildScrollView(
      //         child: Material(
      //           child: Padding(
      //             padding: EdgeInsets.fromLTRB(
      //               Dimens.gap_dp8,
      //               Dimens.gap_dp8,
      //               Dimens.gap_dp8,
      //               Dimens.gap_dp12,
      //             ),
      //             child: SizedBox(
      //               height: Dimens.setWidth(72),
      //               child: Stack(
      //                 alignment: Alignment.center,
      //                 children: [
      //                   ClipRRect(
      //                     borderRadius: BorderRadius.circular(Dimens.gap_dp12),
      //                     child: TextField(
      //                       focusNode: focusNode,
      //                       controller: editingController,
      //                       style: const TextStyle(
      //                         fontWeight: FontWeight.bold,
      //                       ),
      //                       decoration: InputDecoration(
      //                         // border: OutlineInputBorder(
      //                         //   borderRadius: BorderRadius.circular(Dimens.gap_dp8),
      //                         // ),
      //                         border: InputBorder.none,
      //                         filled: true,
      //                         fillColor: Color(0xFFF0F0F0),
      //                       ),
      //                       onSubmitted: (_) {
      //                         execCmd();
      //                       },
      //                     ),
      //                   ),
      //                   Align(
      //                     alignment: Alignment.centerRight,
      //                     child: SizedBox(
      //                       height: Dimens.setWidth(72),
      //                       width: Dimens.setWidth(72),
      //                       child: Material(
      //                         color: Colors.transparent,
      //                         child: IconButton(
      //                           icon: Icon(
      //                             Icons.arrow_forward_ios,
      //                             color: Colors.black.withOpacity(0.6),
      //                           ),
      //                           onPressed: () async {
      //                             execCmd();
      //                           },
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}
