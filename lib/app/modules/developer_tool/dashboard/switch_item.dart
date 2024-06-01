import 'package:adb_kit/app/modules/setting/setting_page.dart';
import 'package:adb_kit/config/font.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class SwitchItem extends StatefulWidget {
  const SwitchItem({
    Key? key,
    this.title,
    this.onOpen,
    this.onClose,
  }) : super(key: key);
  final String? title;
  final bool Function()? onOpen;
  final bool Function()? onClose;
  @override
  State createState() => _SwitchItemState();
}

class _SwitchItemState extends State<SwitchItem> {
  bool isCheck = false;
  @override
  void initState() {
    super.initState();
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
                if (isCheck) {
                  isCheck = widget.onClose!();
                } else {
                  isCheck = widget.onOpen!();
                }
                setState(() {});
              },
            )
          ],
        ),
      ),
    );
  }
}
