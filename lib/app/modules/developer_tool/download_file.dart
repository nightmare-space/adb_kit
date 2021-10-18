// 有动画

import 'package:adb_tool/global/widget/pop_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';

class DownloadFile extends StatefulWidget {
  const DownloadFile({Key key, this.serial}) : super(key: key);
  final String serial;

  @override
  _DownloadFileState createState() => _DownloadFileState();
}

class _DownloadFileState extends State<DownloadFile>
    with SingleTickerProviderStateMixin {
  TextEditingController devicesFilePathCTL = TextEditingController(
    text: '/sdcard/',
  );
  TextEditingController localFilePathCTL = TextEditingController(
    text: PlatformUtil.getDownloadPath(),
  );
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,
        title: Text(
          '下载文件',
          style: TextStyle(
            height: 1.0,
            color: Theme.of(context).textTheme.bodyText2.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const PopButton(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  // color: const Color(0xfff7f7f7),
                ),
                margin: EdgeInsets.symmetric(
                  horizontal: Dimens.gap_dp8,
                ),
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.all(Dimens.gap_dp4),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Text(
                          '设备文件路径',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: devicesFilePathCTL,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: Dimens.gap_dp12,
                                    horizontal: Dimens.gap_dp8,
                                  ),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final String text =
                                    (await Clipboard.getData('text/plain'))
                                        .text;
                                devicesFilePathCTL.text = text;
                              },
                              child: const Text('粘贴'),
                            )
                          ],
                        ),
                        const Text(
                          '下载到的路径',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: localFilePathCTL,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: Dimens.gap_dp12,
                                    horizontal: Dimens.gap_dp8,
                                  ),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final String text =
                                    (await Clipboard.getData('text/plain'))
                                        .text;
                                localFilePathCTL.text = text;
                              },
                              child: const Text('粘贴'),
                            )
                          ],
                        ),
                        // Align(
                        //   alignment: Alignment.centerRight,
                        //   child: TextButton(
                        //     onPressed: () async {
                        //       // print(Map.from(Platform.environment));
                        //       // return;
                        //       final ProcessState processState =
                        //           Global.instance.processState;
                        //       processState.clear();
                        //       final String result = await exec(
                        //         'adb -s ${widget.serial} pull ${devicesFilePathCTL.text} ${localFilePathCTL.text}',
                        //       );

                        //       processState.appendOut(result);
                        //       // final String result = await exec(
                        //       //   'adb -s ${widget.serial} install /Users/nightmare/Desktop/scrcpy_client/scrcpy_client/build/app/outputs/apk/release/app-release.apk',
                        //       // );
                        //       //
                        //       // print(result);
                        //     },
                        //     child: const Text('下载'),
                        //   ),
                        // ),
                        // ConstrainedBox(
                        //   constraints: const BoxConstraints(
                        //     maxHeight: 100,
                        //   ),
                        //   // height: MediaQuery.of(context).size.height * 3 / 4,
                        //   child: const ProcessPage(),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
