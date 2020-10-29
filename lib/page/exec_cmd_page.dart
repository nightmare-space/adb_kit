import 'package:adb_tool/config/dimens.dart';
import 'package:adb_tool/global/provider/process_state.dart';
import 'package:adb_tool/utils/custom_process.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'process_page.dart';

class ExecCmdPage extends StatefulWidget {
  @override
  _ExecCmdPageState createState() => _ExecCmdPageState();
}

class _ExecCmdPageState extends State<ExecCmdPage> {
  TextEditingController editingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ProcessPage(
            height: MediaQuery.of(context).size.height * 3 / 4,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.gap_dp8,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimens.gap_dp8),
                  child: TextField(
                    controller: editingController,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      // border: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(Dimens.gap_dp8),
                      // ),
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.3),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black.withOpacity(0.6),
                    ),
                    onPressed: () {
                      Provider.of<ProcessState>(context).clear();
                      NiProcess.exec(
                        editingController.text,
                        getStderr: true,
                        callback: (s) {
                          print('ss======>$s');
                          if (s.trim() == 'exitCode') {
                            return;
                          }
                          Provider.of<ProcessState>(context).appendOut(s);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
