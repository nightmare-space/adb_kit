import 'package:adb_kit/adb_wrapper.dart';
import 'package:adb_kit/app/controller/controller.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit/global/widget/item_header.dart';
import 'package:adb_util/adb_util_flutter.dart';
import 'package:dart_adb/adb.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:global_repository/global_repository.dart';

import '../../../../global/widget/card_item.dart';
import 'overview_page.dart';

/// 准备直接给 Uncon 复用
class ConnectPairCard extends StatefulWidget {
  const ConnectPairCard({super.key});

  @override
  State<ConnectPairCard> createState() => _ConnectPairCardState();
}

class _ConnectPairCardState extends State<ConnectPairCard> {
  TextEditingController ipController = TextEditingController();
  TextEditingController portCtl = TextEditingController();
  TextEditingController pairCodeCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.replace(ipController, tag: 'ip');
    Get.replace(portCtl, tag: 'port');
  }

  Future<void> connectDevice() async {
    if (ipController.text.isEmpty) {
      showToast(S.current.ipIsEmtpy);
      return;
    }
    Log.d('adb connect ${ipController.text} start');
    DevicesController dc = Get.find();
    ADBConnectResult? result;
    try {
      String suffix = pairCodeCtl.text.isEmpty ? '' : ' ${pairCodeCtl.text}';
      String port = portCtl.text.isEmpty ? '5555' : portCtl.text;
      final onnectResult = await ADBWrapper.connectDevices('${ipController.text}:$port$suffix');
      if (onnectResult is ADBIO) {
        dc.onPureDartADBDeviceConnect('${ipController.text}:${portCtl.text}', onnectResult);
      } else {
        result = onnectResult;
      }
      if (result is SuccessPair) {
        Log.i('Pair success');
        showToast(S.current.pairSuccess);
      }
    } catch (e) {
      if (e is NeedAuthenticate) {
        showToast(S.current.needAuth);
        return;
      }
      Log.e(e);
      showToast('$e');
    }
    Log.d('adb 连接结束 $result');
  }

  @override
  void dispose() {
    ipController.dispose();
    portCtl.dispose();
    pairCodeCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double ipWidth = 110.w;
    return Column(
      children: [
        // Text('注意这个模式需要另一台设备通过数据线辅助打开'),
        CardItem(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ItemHeader(color: CandyColors.candyBlue),
                  Text(
                    S.of(context).inputDeviceAddress,
                    style: TextStyle(
                      fontSize: Dimens.font_sp16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.w),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4.w),
                child: Row(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: ipWidth,
                          child: TextField(
                            controller: ipController,
                            decoration: InputDecoration(
                              labelText: 'IP地址',
                              fillColor: Theme.of(context).colorScheme.surface,
                            ),
                            style: TextStyle(
                              fontSize: 14.w,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        SizedBox(
                          width: 60.w,
                          child: TextField(
                            controller: portCtl,
                            decoration: InputDecoration(
                              labelText: '端口',
                              fillColor: Theme.of(context).colorScheme.surface,
                            ),
                            style: TextStyle(
                              fontSize: 14.w,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        SizedBox(
                          width: 60.w,
                          child: TextField(
                            controller: pairCodeCtl,
                            decoration: InputDecoration(
                              labelText: '配对码',
                              fillColor: Theme.of(context).colorScheme.surface,
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                            style: TextStyle(
                              fontSize: 14.w,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 8.w),
                    ActionButton(
                      onTap: () async {
                        await connectDevice();
                      },
                      child: Text(
                        pairCodeCtl.text.isEmpty ? S.current.connect : S.current.pair,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // SizedBox(height: 12.w),
        // Container(
        //   width: MediaQuery.of(context).size.width,
        //   padding: EdgeInsets.all(8.w),
        //   decoration: BoxDecoration(
        //     color: Colors.red.withOpacity(0.1),
        //     borderRadius: BorderRadius.circular(10.w),
        //   ),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Row(
        //         children: [
        //           Text(
        //             '注意！！！配对端口与连接端口不一样！！！',
        //             style: TextStyle(
        //               color: Colors.red,
        //               fontSize: 12.w,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
        // SizedBox(height: 4.w),
      ],
    );
  }
}
