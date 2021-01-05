import 'dart:io';

import 'package:adb_tool/config/dimens.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({
    Key key,
    this.onChange,
    this.index,
  }) : super(key: key);
  final void Function(int index) onChange;
  final int index;

  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  @override
  Widget build(BuildContext context) {
    double width = 0;
    if (PlatformUtil.isDesktop()) {
      width = MediaQuery.of(context).size.width * 1 / 5;
    } else {
      width = MediaQuery.of(context).size.width * 2 / 3;
    }
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.adb,
                size: Dimens.setWidth(100),
              ),
              _DrawerItem(
                title: '主页',
                value: 0,
                groupValue: widget.index,
                onTap: (index) {
                  widget.onChange?.call(index);
                },
              ),
              if (Platform.isAndroid)
                _DrawerItem(
                  value: 1,
                  groupValue: widget.index,
                  title: '安装到系统',
                  onTap: (index) {
                    widget.onChange?.call(index);
                  },
                ),
              // _DrawerItem(
              //   title: '当前设备ip',
              //   onTap: () {},
              // ),
              if (Platform.isAndroid)
                Column(
                  children: [
                    _DrawerItem(
                      value: 2,
                      groupValue: widget.index,
                      title: '查看连接到本机的ip',
                      onTap: (index) {
                        widget.onChange?.call(index);
                      },
                    ),
                    _DrawerItem(
                      value: 3,
                      groupValue: widget.index,
                      title: '远程调试',
                      onTap: (index) {
                        widget.onChange?.call(index);
                      },
                    ),
                  ],
                ),
              _DrawerItem(
                value: 4,
                groupValue: widget.index,
                title: '执行自定义命令',
                onTap: (index) {
                  widget.onChange?.call(index);
                },
              ),
              _DrawerItem(
                value: 5,
                groupValue: widget.index,
                title: '电脑版下载',
                onTap: (index) {
                  // widget.onChange?.call(index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color accent = const Color(0xff282b3e);

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    Key key,
    this.title,
    this.onTap,
    this.value,
    this.groupValue,
  }) : super(key: key);
  final String title;
  final void Function(int index) onTap;
  final int value;
  final int groupValue;
  @override
  Widget build(BuildContext context) {
    final bool isChecked = value == groupValue;
    return InkWell(
      onTap: () => onTap(value),
      child: Stack(
        children: [
          Container(
            height: 48.0,
            width: 240,
            decoration: isChecked
                ? BoxDecoration(
                    color: accent,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  )
                : null,
          ),
          SizedBox(
            height: 52,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: isChecked ? Colors.white : Colors.black,
                    fontSize: Dimens.font_sp14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
