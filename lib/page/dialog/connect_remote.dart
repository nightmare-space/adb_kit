import 'dart:io';

import 'package:adb_tool/config/dimens.dart';
import 'package:adb_tool/global/provider/process_state.dart';
import 'package:adb_tool/utils/custom_process.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnectRemote extends StatefulWidget {
  @override
  _ConnectRemoteState createState() => _ConnectRemoteState();
}

class _ConnectRemoteState extends State<ConnectRemote> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: 300,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.gap_dp8,
          ),
          child: Column(
            children: [
              const Text(
                '连接远程设备',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: Dimens.gap_dp8,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(Dimens.gap_dp8),
                child: TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    fillColor: Colors.grey.withOpacity(0.4),
                    filled: true,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FlatButton(
                  onPressed: () async {
                    Navigator.of(context)
                        .pop('adb connect ${textEditingController.text}');
                  },
                  child: Text('连接'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
