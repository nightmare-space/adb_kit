import 'package:flutter/material.dart' hide TabController;
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'app/controller/controller.dart';
import 'app/modules/home/views/adaptive_view.dart';
import 'global/instance/global.dart';

class ADBToolEntryPoint extends StatefulWidget {
  const ADBToolEntryPoint({
    Key? key,
  }) : super(key: key);

  @override
  State<ADBToolEntryPoint> createState() => _ADBToolEntryPointState();
}

class _ADBToolEntryPointState extends State<ADBToolEntryPoint> {
  TabController controller = Get.put(TabController(), permanent: true);

  @override
  void initState() {
    super.initState();
    controller.setInitPage(
      PageEntity(
        title: 'ADB KIT',
        page: Stack(
          children: [
            GetBuilder<ConfigController>(builder: (config) {
              if (config.backgroundStyle == BackgroundStyle.normal) {
                return Container(
                  color: config.theme!.colorScheme.background,
                );
              }
              if (config.backgroundStyle == BackgroundStyle.image) {
                return SizedBox(
                  height: double.infinity,
                  child: Image.asset(
                    'assets/b.png',
                    fit: BoxFit.cover,
                  ),
                );
              } else {
                return const SizedBox();
              }
            }),
            GetBuilder<ConfigController>(
              builder: (config) {
                return Theme(data: config.theme!, child: const ADBKITAdaptiveRootWidget());
              },
            ),
          ],
        ),
      ),
    );
  }

  //Create an instance of ScreenshotController

  @override
  Widget build(BuildContext context) {
    return Global().rootWidget ??= GetBuilder<TabController>(
      autoRemove: false,
      builder: (controller) {
        return Column(
          children: [
            TopTab(
              onChanged: (int index) {
                controller.changePage(index);
                Log.d(index);
              },
              children: [
                for (PageEntity page in controller.pages)
                  Text(
                    page.title,
                    style: TextStyle(
                      fontSize: 12.w,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
              ],
            ),
            Builder(builder: (context) {
              // ignore: avoid_print
              print('controller.pageindex -> ${controller.pageindex} controller.pages.length -> ${controller.pages.length}');
              return Expanded(
                child: controller.pages[controller.pageindex].page,
              );
            }),
          ],
        );
      },
    );
  }
}
