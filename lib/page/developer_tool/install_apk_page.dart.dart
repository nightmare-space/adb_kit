// 有动画
import 'package:adb_tool/config/dimens.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/global/widget/pop_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';

class InstallApkPage extends StatefulWidget {
  const InstallApkPage({Key key, this.serial}) : super(key: key);
  final String serial;

  @override
  _InstallApkPageState createState() => _InstallApkPageState();
}

class _InstallApkPageState extends State<InstallApkPage>
    with SingleTickerProviderStateMixin {
  TextEditingController devicesFilePathCTL = TextEditingController(
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
          '安装apk',
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
                          'apk路径',
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
                        // Align(
                        //   alignment: Alignment.centerRight,
                        //   child: FlatButton(
                        //     onPressed: () async {
                        //       final ProcessState processState =
                        //           Global.instance.processState;
                        //       processState.clear();
                        //       NiProcess.exec(
                        //         'adb -s ${widget.serial} install ${devicesFilePathCTL.text}',
                        //         getStderr: true,
                        //         callback: (s) {
                        //           print('ss======>$s');
                        //           if (s.trim() == 'exitCode') {
                        //             return;
                        //           }
                        //           processState.appendOut(s);
                        //         },
                        //       );
                        //       // final String result = await exec(
                        //       //   'adb -s ${widget.serial} install /Users/nightmare/Desktop/scrcpy_client/scrcpy_client/build/app/outputs/apk/release/app-release.apk',
                        //       // );
                        //       //
                        //       // print(result);
                        //     },
                        //     child: const Text('安装'),
                        //   ),
                        // ),
                        // const ProcessPage(
                        //   height: 100,
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
