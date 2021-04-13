import 'package:adb_tool/app/modules/home/bindings/home_binding.dart';
import 'package:adb_tool/app/modules/home/views/home_view.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
  ];
}
