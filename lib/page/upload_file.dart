// 有动画
import 'package:adb_tool/config/dimens.dart';
import 'package:adb_tool/config/global.dart';
import 'package:adb_tool/global/provider/process_info.dart';
import 'package:adb_tool/global/widget/pop_button.dart';
import 'package:adb_tool/utils/custom_process.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'process_page.dart';

class UploadFile extends StatefulWidget {
  const UploadFile({Key key, this.serial}) : super(key: key);
  final String serial;

  @override
  _UploadFileState createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile>
    with SingleTickerProviderStateMixin {
  TextEditingController devicesFilePathCTL = TextEditingController(
    text: '',
  );
  TextEditingController localFilePathCTL = TextEditingController(
    text: '/sdcard/',
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
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,
        title: Text(
          '上传文件',
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
                          '选择上传文件路径',
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
                            FlatButton(
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
                          '上传到的路径',
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
                            FlatButton(
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: FlatButton(
                            onPressed: () async {
                              final ProcessState processState =
                                  Global.instance.processState;
                              processState.clear();
                              // final String result = await exec(
                              //   'adb -s ${widget.serial} push ${devicesFilePathCTL.text} ${localFilePathCTL.text}',
                              // );
                              NiProcess.exec(
                                '/Users/nightmare/Desktop/nightmare-space/adb_tool/lib/page/list/1.sh',
                                getStderr: true,
                                callback: (s) {
                                  print('ss======>$s');
                                  if (s.trim() == 'exitCode') {
                                    return;
                                  }
                                  processState.appendOut(s);
                                },
                              );
                              // final String result = await exec(
                              //   '/Users/nightmare/Desktop/nightmare-space/adb_tool/lib/page/list/1.sh',
                              // );

                              // final String result = await exec(
                              //   'adb -s ${widget.serial} install /Users/nightmare/Desktop/scrcpy_client/scrcpy_client/build/app/outputs/apk/release/app-release.apk',
                              // );
                              //
                              // print(result);
                            },
                            child: const Text('上传'),
                          ),
                        ),
                        const ProcessPage(),
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
