import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/config/dimens.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class ConnectRemote extends StatefulWidget {
  @override
  _ConnectRemoteState createState() => _ConnectRemoteState();
}

class _ConnectRemoteState extends State<ConnectRemote> {
  TextEditingController textEditingController =
      TextEditingController(text: Config.historyIp);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FullHeightListView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.gap_dp8,
          vertical: Dimens.gap_dp8,
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                controller: textEditingController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: const Color(0xfff0f0f0),
                  filled: true,
                  labelText: '输入设备的 ip 地址',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: Dimens.gap_dp4,
                    horizontal: Dimens.gap_dp8,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: Dimens.gap_dp12,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  Config.historyIp = textEditingController.text;
                  Navigator.of(context).pop(
                    'adb connect ${textEditingController.text}\n',
                  );
                },
                child: const Text('连接'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
