import 'dart:math';

import 'package:adb_tool/app/controller/history_controller.dart';
import 'package:adb_tool/config/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class ConnectRemote extends StatefulWidget {
  @override
  _ConnectRemoteState createState() => _ConnectRemoteState();
}

class _ConnectRemoteState extends State<ConnectRemote> {
  TextEditingController ipController = TextEditingController();
  TextEditingController portEditCTL = TextEditingController(text: '5555');
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    ipController.dispose();
    portEditCTL.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FullHeightListView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.gap_dp8,
          vertical: Dimens.gap_dp4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '连接远程设备',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Dimens.font_sp16,
              ),
            ),
            SizedBox(
              height: Dimens.gap_dp16,
            ),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimens.gap_dp8),
                    child: TextField(
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      controller: ipController,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        fillColor: const Color(0xfff0f0f0),
                        filled: true,
                        hintText: 'ip',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: Dimens.gap_dp12,
                          horizontal: Dimens.gap_dp8,
                        ),
                      ),
                    ),
                  ),
                ),
                const Text(' : '),
                SizedBox(
                  width: Dimens.setWidth(100),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimens.gap_dp8),
                    child: TextField(
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      controller: portEditCTL,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        fillColor: const Color(0xfff0f0f0),
                        filled: true,
                        hintText: 'port',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: Dimens.gap_dp12,
                          horizontal: Dimens.gap_dp8,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: Dimens.gap_dp12,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  final String data = ipController.text;
                  if (data.isEmpty) {
                    showToast('输入不能为空');
                    return;
                  }
                  Config.historyIp = ipController.text;
                  if (!Config.historyIp.isIPv4 && !Config.historyIp.isIPv6) {
                    showToast('请输入标准的ipv4或ipv6地址');
                    return;
                  }
                  Navigator.of(context).pop(
                    'adb connect ${ipController.text}:${portEditCTL.text}\n',
                  );
                  final HistoryController historyController = Get.find();
                  historyController.addAdbEntity(
                    AdbEntity(
                      ipController.text,
                      portEditCTL.text,
                      DateTime.now(),
                    ),
                  );
                },
                child: const Text('连接'),
              ),
            ),
            Text('历史地址'),
            Builder(
              builder: (_) {
                final HistoryController controller = Get.find();
                if (controller.adbEntitys.isEmpty) {
                  return Text('空');
                }
                return SizedBox(
                  height: max(
                    Dimens.gap_dp56 * controller.adbEntitys.length,
                    300,
                  ),
                  child: ListView.builder(
                    itemCount: controller.adbEntitys.length,
                    itemBuilder: (c, i) {
                      AdbEntity adbEntity = controller.adbEntitys.toList()[i];
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).pop(
                            'adb connect ${adbEntity.ip}:${adbEntity.port}\n',
                          );
                        },
                        child: SizedBox(
                          height: Dimens.gap_dp56,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimens.gap_dp16,
                              ),
                              child: Text(
                                '${controller.adbEntitys.toList()[i]}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
