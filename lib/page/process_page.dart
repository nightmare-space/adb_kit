import 'dart:convert';

import 'package:adb_tool/config/dimens.dart';
import 'package:adb_tool/global/provider/process_state.dart';
import 'package:adb_tool/global/widget/custom_list.dart';
import 'package:adb_tool/utils/custom_process.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProcessPage extends StatefulWidget {
  const ProcessPage({Key key, this.height = 400}) : super(key: key);
  final double height;
  @override
  _ProcessPageState createState() => _ProcessPageState();
}

class _ProcessPageState extends State<ProcessPage> {
  String cmdOut = '';
  @override
  void initState() {
    super.initState();
    // getProcessOut();
  }

  // Future<void> getProcessOut() async {
  //   // await NiProcess.ensureInitialized();
  //   await Future<void>.delayed(Duration(seconds: 1));

  //   NiProcess.processStderr.transform(utf8.decoder).listen((event) {
  //     cmdOut += event.toString();
  //     setState(() {});
  //     print(event);
  //   });
  //   NiProcess.processStdout.transform(utf8.decoder).listen((event) {
  //     cmdOut += event.toString();
  //     setState(() {});
  //     print(event);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final ProcessState processState = Provider.of<ProcessState>(context);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: Dimens.setWidth(widget.height),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Padding(
        padding: EdgeInsets.all(Dimens.gap_dp16),
        child: Container(
          padding: EdgeInsets.all(Dimens.gap_dp8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F1F3),
            borderRadius: BorderRadius.circular(
              Dimens.gap_dp12,
            ),
          ),
          width: MediaQuery.of(context).size.width,
          child: Scrollbar(
            child: CustomList(
              child: Text(
                processState.output == '' ? '等待输入' : processState.output.trim(),
                style: TextStyle(
                  fontSize: Dimens.font_sp18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
