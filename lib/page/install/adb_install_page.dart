import 'dart:io';
import 'dart:typed_data';
import 'package:adb_tool/config/dimens.dart';
import 'package:adb_tool/global/widget/custom_card.dart';
import 'package:adb_tool/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:global_repository/global_repository.dart';

class AdbInstallPage extends StatefulWidget {
  @override
  _AdbInstallPageState createState() => _AdbInstallPageState();
}

class _AdbInstallPageState extends State<AdbInstallPage> {
  @override
  void initState() {
    super.initState();
    // init();
  }

  Future<void> init() async {
    String result = await NiProcess.exec('echo \$PATH');
    print('result->$result');
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
          '未找到Adb',
          style: TextStyle(
            height: 1.0,
            color: Theme.of(context).textTheme.bodyText2.color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          _DownloadFile(),
        ],
      ),
    );
  }
}

class _DownloadFile extends StatefulWidget {
  const _DownloadFile({Key key, this.callback}) : super(key: key);
  final void Function() callback;
  @override
  _DownloadFileState createState() => _DownloadFileState();
}

class _DownloadFileState extends State<_DownloadFile> {
  final Dio dio = Dio();
  Response<String> response;
  final String filesPath = PlatformUtil.getBinaryPath();
  List<String> androidAdbFiles = [
    'http://nightmare.fun/YanTool/android/adb',
    'http://nightmare.fun/YanTool/android/adb.bin'
  ];
  List<String> macAdbFiles = [
    'http://nightmare.fun/File/MToolkit/mac/adb.zip',
  ];
  List<String> winAdbFiles = [
    'http://nightmare.fun/File/MToolkit/windows/adb.exe',
    'http://nightmare.fun/File/MToolkit/windows/AdbWinUsbApi.dll',
    'http://nightmare.fun/File/MToolkit/windows/AdbWinApi.dll',
  ];
  double fileDownratio = 0.0;
  String downloadName = '';
  Future<void> downloadFile(String assetKey) async {
    final ByteData byteData = await rootBundle.load(
      assetKey,
    );
    final Uint8List picBytes = byteData.buffer.asUint8List();
    final String savePath =
        filesPath + Platform.pathSeparator + PlatformUtil.getFileName(assetKey);
    final File file = File(savePath);
    IOSink ioSink = file.openWrite();
    if (!await file.exists()) {
      await file.writeAsBytes(picBytes);
      await Process.run('chmod', <String>['+x', savePath]);
    }
    // installModule(savePath);
  }

  void installModule(String modulePath) {
    Process.runSync('sh', <String>[
      '-c',
      'unzip -o $modulePath -d ${PlatformUtil.getTmpPath()}/ \n' +
          'mv ${PlatformUtil.getTmpPath()}/* ${PlatformUtil.getBinaryPath()}/ \n' +
          'chmod 0777 ${PlatformUtil.getBinaryPath()}/* \n',
    ]);
  }

  @override
  void initState() {
    super.initState();
    execDownload();
  }

  Future<void> execDownload() async {
    List<String> needDownloadFile;
    if (Platform.isWindows) {
      needDownloadFile = winAdbFiles;
    } else if (Platform.isMacOS) {
      needDownloadFile = macAdbFiles;
    }
    if (Platform.isAndroid) {
      needDownloadFile = androidAdbFiles;
    }
    for (final String urlPath in needDownloadFile) {
      downloadName = PlatformUtil.getFileName(urlPath);
      setState(() {});
      await downloadFile(urlPath);
    }
    Navigator.of(context).pushReplacement<MaterialPageRoute, void>(
      MaterialPageRoute(builder: (_) {
        return AdbTool();
      }),
    );
    widget.callback?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(
        Dimens.gap_dp8,
      ),
      child: NiCardButton(
        child: Padding(
          padding: EdgeInsets.all(
            12.w.toDouble(),
          ),
          child: Column(
            children: [
              Text(
                '下载 $downloadName 中',
                style: TextStyle(
                  fontSize: 18.w.toDouble(),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '进度',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: Dimens.gap_dp12,
              ),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                child: LinearProgressIndicator(
                  value: fileDownratio,
                ),
              ),
              SizedBox(
                child: Text(
                  '下载到的目录为 $filesPath',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: Dimens.font_sp12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
