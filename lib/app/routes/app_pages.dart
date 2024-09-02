import 'package:adb_kit/adbkit_entrypoint.dart';
import 'package:adb_kit/app/modules/home/bindings/home_binding.dart';
import 'package:adb_kit/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
part 'app_routes.dart';

class ADBPages {
  ADBPages._();
  static const initial = Routes.home;
  static const splash = '/splash';

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => const ADBToolEntryPoint(),
      binding: HomeBinding(),
      transition: Transition.zoom,
      customTransition: RouteTransition(
        route: Routes.home,
      ),
      transitionDuration: const Duration(milliseconds: 1200),
    ),
    GetPage(
      name: splash,
      page: () => const SplashPage(),
      customTransition: RouteTransition(
        route: splash,
      ),
      transitionDuration: const Duration(milliseconds: 1000),
    ),
  ];
}

Widget getWidget(String route) {
  switch (route) {
    default:
      return const SizedBox();
  }
}

class RouteTransition implements CustomTransition {
  final String route;

  RouteTransition({required this.route});
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    Animation<double> frontRoute = Tween(begin: 2.0, end: 1.0).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0, 1.0, curve: Curves.easeIn),
    ));

    Animation<double> backRouteScale = Tween(begin: 1.0, end: 2.0).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0, 1.0, curve: Curves.easeOut),
    ));
    Animation<double> backRouteOpacity = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0, 1.0, curve: Curves.easeOut),
    ));
    // Log.i('$route secondaryAnimation.value:${secondaryAnimation.value}');
    // Log.i('$route animation.value:${animation.value}');
    return Stack(
      children: [
        if (secondaryAnimation.value != 0)
          ScaleTransition(
            scale: backRouteScale,
            child: FadeTransition(
              opacity: backRouteOpacity,
              child: child,
            ),
          )
        else
          ScaleTransition(
            scale: frontRoute,
            child: Builder(builder: (context) {
              if (animation.value < 0.8) {
                return const SizedBox();
              }
              return Opacity(
                opacity: animation.value,
                child: child,
              );
            }),
          ),
      ],
    );
  }
}
