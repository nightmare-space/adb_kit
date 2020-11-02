import 'package:adb_tool/config/dimens.dart';
import 'package:flutter/material.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({Key key, this.onChange}) : super(key: key);
  final void Function(String key) onChange;

  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.adb,
              size: Dimens.setWidth(100),
            ),
            _DrawerItem(
              title: '概况',
              onTap: () {
                widget.onChange?.call('main');
              },
            ),
            _DrawerItem(
              title: '安装到系统',
              onTap: () {
                widget.onChange?.call('install-adb');
              },
            ),
            _DrawerItem(
              title: '当前设备ip',
              onTap: () {},
            ),
            _DrawerItem(
              title: '查看连接到本机的ip',
              onTap: () {
                widget.onChange?.call('search-ip');
              },
            ),
            _DrawerItem(
              title: '执行自定义命令',
              onTap: () {
                widget.onChange?.call('exec-cmd');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({Key key, this.title, this.onTap}) : super(key: key);
  final String title;
  final void Function() onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
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
                fontSize: Dimens.font_sp14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
