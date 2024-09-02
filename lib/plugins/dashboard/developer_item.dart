import 'package:adb_kit/app/modules/setting/setting_page.dart';
import 'package:adb_kit/config/font.dart';
import 'package:adbutil/adbutil.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class DeveloperItem extends StatefulWidget {
  const DeveloperItem({
    Key? key,
    this.title,
    this.serial,
    this.putKey,
  }) : super(key: key);
  final String? title;
  final String? serial;
  final String? putKey;
  @override
  State createState() => _DeveloperItemState();
}

class _DeveloperItemState extends State<DeveloperItem> {
  bool isCheck = false;
  @override
  void initState() {
    super.initState();
    initCheckState();
  }

  Future<void> initCheckState() async {
    final String result = await execCmd(
      '$adb -s ${widget.serial} shell settings get system ${widget.putKey}',
    );
    // Log.w('result -> $result');
    if (result == '1') {
      isCheck = true;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 48.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title!,
              style: TextStyle(
                fontWeight: bold,
                fontSize: 16.w,
              ),
            ),
            AquaSwitch(
              value: isCheck,
              onChanged: (_) {
                isCheck = !isCheck;
                final int value = isCheck ? 1 : 0;
                execCmd(
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
