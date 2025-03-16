import 'dart:async';

import 'package:adb_kit/adb_wrapper.dart';
import 'package:adb_kit/app/controller/controller.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit/global/widget/item_header.dart';
import 'package:adb_kit/utils/adbd_find_util.dart';
import 'package:adb_util/adb_util.dart';
import 'package:dart_adb/adb.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import '../../../../global/widget/card_item.dart';
import 'overview_page.dart';

/// 准备直接给 Uncon 复用
class FindCard extends StatefulWidget {
  const FindCard({super.key});

  @override
  State<FindCard> createState() => _FindCardState();
}

class _FindCardState extends State<FindCard> {
  Set<(String, int)> findDevices = {};
  TextEditingController ipController = TextEditingController();
  TextEditingController portController = TextEditingController(text: '5555');
  Future<void> connectDevice() async {
    if (ipController.text.isEmpty) {
      showToast('IP不可为空');
      return;
    }
    Log.d('adb connect ${ipController.text} start');
    DevicesController dc = Get.find();
    ADBConnectResult? result;
    try {
      final onnectResult = await ADBWrapper.connectDevices('${ipController.text}:${portController.text}');
      if (onnectResult is ADBIO) {
        dc.onPureDartADBDeviceConnect('${ipController.text}:${portController.text}', onnectResult);
      } else {
        result = onnectResult;
      }
      if (result is SuccessPair) {
        Log.i('配对成功，请删除配对码，修改连接端口，连接设备');
        showToast('配对成功，请删除配对码，修改连接端口，连接设备');
      }
    } catch (e) {
      if (e is NeedAuthenticate) {
        Log.i(S.current.needAuth);
        showToast(S.current.needAuth);
        return;
      }
      Log.e(e);
      showToast('$e');
    }
    Log.d('adb 连接结束 $result');
  }

  Timer? connectTimer;
  Timer? pairTimer;

  @override
  void initState() {
    super.initState();

    getLanDevice();
  }

  Future<void> getLanDevice() async {
    connectTimer = await listenConnectDeivce(
      (device) {
        findDevices.add(device);
        setState(() {});
      },
    );
    pairTimer = await listenPairDeivce(
      (device) {
        findDevices.add(device);
        setState(() {});
      },
    );
    List<String> adbDevices = await ADBFind.getLANDevices();
    for (String device in adbDevices) {
      findDevices.add((device, 5555));
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    connectTimer?.cancel();
    pairTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return CardItem(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ItemHeader(color: CandyColors.candyGreen),
              // 加上一个 MDNS 和 端口扫描 的开关
              Text(
                '端口扫描',
                style: TextStyle(
                  fontSize: Dimens.font_sp16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.w),
          Wrap(
            children: [
              for (dynamic device in findDevices)
                InkWell(
                  onTap: () {
                    TextEditingController ipController = Get.find(tag: 'ip');
                    TextEditingController portController = Get.find(tag: 'port');
                    ipController.text = device.$1;
                    portController.text = device.$2.toString();
                  },
                  borderRadius: BorderRadius.circular(8.w),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.w,
                    ),
                    child: Text(
                      '${device.$1}:${device.$2}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
