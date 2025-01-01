import 'package:adb_kit/app/modules/setting/setting_page.dart';
import 'package:adb_kit/config/font.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart' hide exec;
import 'package:adb_util/adb_util.dart';
import 'package:adb_kit/adb_kit.dart';
import 'package:get/get.dart';
import 'package:adb_kit/app/controller/controller.dart';

class DashboardSwitchItem extends StatefulWidget {
  const DashboardSwitchItem({
    super.key,
    required this.title,
    this.onOpen,
    this.onClose,
    this.init,
  });
  final Widget title;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;
  final Future<bool> Function()? init;

  @override
  State<DashboardSwitchItem> createState() => _DashboardSwitchItemState();
}

class _DashboardSwitchItemState extends State<DashboardSwitchItem> {
  bool value = false;
  @override
  void initState() {
    super.initState();
    widget.init?.call().then((value) {
      this.value = value;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DefaultTextStyle(
          style: TextStyle(
            fontSize: 14.w,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          child: widget.title,
        ),
        AquaSwitch(
          value: value,
          onChanged: (value) {
            this.value = value;
            setState(() {});
            if (value) {
              widget.onOpen?.call();
            } else {
              widget.onClose?.call();
            }
          },
        )
      ],
    );
  }
}

class DeveloperItem extends StatefulWidget {
  const DeveloperItem({
    super.key,
    this.title,
    this.serial,
    this.putKey,
  });
  final String? title;
  final String? serial;
  final String? putKey;
  @override
  State createState() => _DeveloperItemState();
}

class _DeveloperItemState extends State<DeveloperItem> {
  bool isCheck = false;

  ConfigController configController = Get.find();
  String get password => configController.password;
  @override
  void initState() {
    super.initState();
    initCheckState();
  }

  Future<void> initCheckState() async {
    final String result = await getSystem(
      serial: widget.serial!,
      key: widget.putKey!,
      password: password,
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
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 48.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                widget.title ?? '',
                style: TextStyle(
                  fontWeight: bold,
                  fontSize: 16.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
