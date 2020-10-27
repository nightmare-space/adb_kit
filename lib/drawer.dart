import 'package:flutter/material.dart';

class DrawerPage extends StatefulWidget {
  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 80,
          ),
          _DrawerItem(
            title: '概况',
            onTap: () {},
          ),
          _DrawerItem(
            title: '当前设备ip',
            onTap: () {},
          ),
          _DrawerItem(
            title: '查看连接到本机的ip',
            onTap: () {},
          ),
          _DrawerItem(
            title: '执行自定义命令',
            onTap: () {},
          ),
          _DrawerItem(
            title: '连接局域网设备',
            onTap: () {},
          ),
          _DrawerItem(
            title: '上传/下载文件',
            onTap: () {},
          ),
          _DrawerItem(
            title: '向设备安装apk',
            onTap: () {},
          ),
        ],
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
