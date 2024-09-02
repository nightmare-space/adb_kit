import 'package:adb_kit/app/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

// adb output -> please input verify password
class PasswordDialog extends StatefulWidget {
  const PasswordDialog({super.key});

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  ConfigController configController = Get.find();
  late TextEditingController controller = TextEditingController(text: configController.password);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300.w,
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8.w),
              Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: Text(
                  '输入密码',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.w),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    fillColor: Theme.of(context).colorScheme.surfaceContainer,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 4.w, horizontal: 8.w),
                  // TODO intl
                  child: Center(
                    child: Text(
                      '这个密码在adb请求密码的时候会自动输入到终端',
                      style: TextStyle(
                        fontSize: 12.w,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      configController.changePassword(controller.text);
                      Get.back();
                    },
                    child: Text('确定'),
                  ),
                  SizedBox(width: 8.w),
                ],
              ),
              SizedBox(height: 8.w),
            ],
          ),
        ),
      ),
    );
  }
}
