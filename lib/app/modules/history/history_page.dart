import 'package:adb_tool/app/controller/history_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:global_repository/global_repository.dart';

class HistoryPage extends GetView<HistoryController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        title: const Text('历史连接'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      body: ListView.builder(
        itemCount: controller.adbEntitys.length,
        itemBuilder: (c, i) {
          return InkWell(
            onTap: () {},
            child: SizedBox(
              height: Dimens.gap_dp56,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.gap_dp16,
                  ),
                  child: Text(
                    '${controller.adbEntitys.toList()[i]}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
