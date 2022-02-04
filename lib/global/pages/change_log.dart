import 'package:adb_tool/app/modules/overview/pages/overview_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';

class ChangeNode {
  ChangeNode(this.title, this.summary);

  final String title;
  final String summary;
}

class ChangeLog extends StatefulWidget {
  const ChangeLog({Key key}) : super(key: key);

  @override
  _ChangeLogState createState() => _ChangeLogState();
}

class _ChangeLogState extends State<ChangeLog> {
  List<ChangeNode> changes = [];
  @override
  void initState() {
    super.initState();
    newMethod();
  }

  Future<void> newMethod() async {
    String data = await rootBundle.loadString('CHANGELOG.md');
    Log.i(data);
    RegExp regExp = RegExp('##');
    Log.w(data.split(regExp));
    for (String line in data.split(regExp)) {
      String title = line.split('\n').first.trim();
      String summary = line.replaceAll(title, '').trim();
      changes.add(ChangeNode(title, summary));
    }
    changes.removeAt(0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('更新日志'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: changes.length,
          itemBuilder: (c, i) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(changes[i].title),
                  ),
                  CardItem(
                    padding: EdgeInsets.all(10.w),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(changes[i].summary),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
