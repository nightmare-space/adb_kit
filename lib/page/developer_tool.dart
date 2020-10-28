import 'package:adb_tool/config/dimens.dart';
import 'package:adb_tool/utils/process_util.dart';
import 'package:flutter/material.dart';

class DeveloperTool extends StatefulWidget {
  const DeveloperTool({Key key, this.serial}) : super(key: key);
  final String serial;
  @override
  _DeveloperToolState createState() => _DeveloperToolState();
}

class _DeveloperToolState extends State<DeveloperTool> {
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
      body: Column(
        children: [
          DeveloperItem(
            serial: widget.serial,
            title: '显示点按操作反馈',
            putKey: 'show_touches',
          ),
          DeveloperItem(
            serial: widget.serial,
            title: '显示屏幕指针',
            putKey: 'pointer_location',
          ),
          SizedBox(
            height: Dimens.gap_dp48,
            child: Text('上传文件'),
          ),
          SizedBox(
            height: Dimens.gap_dp48,
            child: Text('下载文件'),
          ),
        ],
      ),
    );
  }
}

class DeveloperItem extends StatefulWidget {
  const DeveloperItem({Key key, this.title, this.serial, this.putKey})
      : super(key: key);
  final String title;
  final String serial;
  final String putKey;
  @override
  _DeveloperItemState createState() => _DeveloperItemState();
}

class _DeveloperItemState extends State<DeveloperItem> {
  bool isCheck = false;
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
                int value = isCheck ? 1 : 0;
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
