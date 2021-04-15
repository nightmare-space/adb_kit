import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

import 'install_apk_page.dart.dart';
import 'upload_file.dart';

class DeveloperTool extends StatefulWidget {
  const DeveloperTool({Key key, this.serial, this.providerContext})
      : super(key: key);
  final String serial;
  final BuildContext providerContext;
  @override
  _DeveloperToolState createState() => _DeveloperToolState();
}

class _DeveloperToolState extends State<DeveloperTool> {
  @override
  void initState() {
    super.initState();
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
          '开发者工具',
          style: TextStyle(
            height: 1.0,
            color: Theme.of(context).textTheme.bodyText2.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Builder(
          builder: (_) {
            return IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: Dimens.gap_dp48,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.gap_dp12,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '设备序列号    ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            widget.serial,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _DeveloperItem(
              serial: widget.serial,
              title: '显示点按操作反馈',
              putKey: 'show_touches',
            ),
            _DeveloperItem(
              serial: widget.serial,
              title: '开启单手模式',
              putKey: 'handy_mode_state',
            ),
            InkWell(
              onTap: () {
                exec(
                  'adb -s ${widget.serial} shell settings put system handy_mode_state 1\n'
                  'adb -s ${widget.serial} shell settings put system handy_mode_size 5.5\n'
                  'adb -s ${widget.serial} shell am broadcast -a miui.action.handymode.changemode --ei mode 2\n',
                );
              },
              child: SizedBox(
                height: Dimens.gap_dp48,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.gap_dp12,
                  ),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '开启单手模式',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                // Navigator.of(context).push<void>(
                //   MaterialPageRoute(
                //     builder: (_) {
                //       return UploadFile(
                //         serial: widget.serial,
                //       );
                //     },
                //   ),
                // );
              },
              child: SizedBox(
                height: Dimens.gap_dp48,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.gap_dp12,
                  ),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '一键转无线调试',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _DeveloperItem(
              serial: widget.serial,
              title: '显示屏幕指针',
              putKey: 'pointer_location',
            ),
            _OpenRemoteDebug(
              serial: widget.serial,
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) {
                      return UploadFile(
                        serial: widget.serial,
                      );
                    },
                  ),
                );
              },
              child: SizedBox(
                height: Dimens.gap_dp48,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.gap_dp12,
                  ),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '上传文件',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                // showDialog<void>(
                //   context: context,
                //   child: DownloadFile(
                //     serial: widget.serial,
                //   ),
                // );
              },
              child: SizedBox(
                height: Dimens.gap_dp48,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.gap_dp12,
                  ),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '下载文件',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) {
                      return InstallApkPage(
                        serial: widget.serial,
                      );
                    },
                  ),
                );
              },
              child: SizedBox(
                height: Dimens.gap_dp48,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.gap_dp12,
                  ),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '向设备安装apk',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
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

class _OpenRemoteDebug extends StatefulWidget {
  const _OpenRemoteDebug({
    Key key,
    this.serial,
  }) : super(key: key);
  final String serial;
  @override
  __OpenRemoteDebugState createState() => __OpenRemoteDebugState();
}

class __OpenRemoteDebugState extends State<_OpenRemoteDebug> {
  bool isCheck = false;
  @override
  void initState() {
    super.initState();
    initCheckState();
  }

  Future<void> initCheckState() async {
    final String result = await exec(
      'adb -s ${widget.serial} shell getprop service.adb.tcp.port',
    );
    print(result);
    if (result == '5555') {
      isCheck = true;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: Dimens.gap_dp12,
        ),
        width: MediaQuery.of(context).size.width,
        height: Dimens.gap_dp48,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '为设备开启远程调试',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isAddress(widget.serial) ? '(当前方式:远程)' : '(当前方式:usb)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const Text(
                  '无需root可让设备打开远程调试',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Switch(
              value: isCheck,
              onChanged: (_) async {
                isCheck = !isCheck;
                final int value = isCheck ? 5555 : -1;
                // String result = await exec(
                //   'adb -s ${widget.serial} shell setprop service.adb.tcp.port $value\n'
                //   'adb -s ${widget.serial} shell stop adbd\n'
                //   'adb -s ${widget.serial} shell start adbd\n',
                // );
                // print(result);
                String result;
                if (isCheck) {
                  result = await exec(
                    'adb -s ${widget.serial} shell setprop service.adb.tcp.port $value\n'
                    'adb -s ${widget.serial} tcpip 5555',
                  );
                } else {
                  result = await exec(
                    'adb -s ${widget.serial} shell setprop service.adb.tcp.port $value\n'
                    'adb -s ${widget.serial} usb',
                  );
                }
                print(result);
                setState(() {});
              },
            )
          ],
        ),
      ),
    );
  }
}

class _DeveloperItem extends StatefulWidget {
  const _DeveloperItem({
    Key key,
    this.title,
    this.serial,
    this.putKey,
    this.putType,
  }) : super(key: key);
  final String title;
  final String serial;
  final String putKey;
  final String putType;
  @override
  __DeveloperItemState createState() => __DeveloperItemState();
}

class __DeveloperItemState extends State<_DeveloperItem> {
  bool isCheck = false;
  @override
  void initState() {
    super.initState();
    initCheckState();
  }

  Future<void> initCheckState() async {
    final String result = await exec(
      'adb -s ${widget.serial} shell settings get system ${widget.putKey}',
    );
    if (result == '1') {
      isCheck = true;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: Dimens.gap_dp12,
        ),
        width: MediaQuery.of(context).size.width,
        height: Dimens.gap_dp48,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Switch(
              value: isCheck,
              onChanged: (_) {
                isCheck = !isCheck;
                final int value = isCheck ? 1 : 0;
                print(
                    'adb -s ${widget.serial} shell settings put system show_touches 1');
                exec(
                  'adb -s ${widget.serial} shell settings put system ${widget.putKey} $value',
                );

                setState(() {});
              },
            )
          ],
        ),
      ),
    );
  }
}
