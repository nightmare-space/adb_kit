import 'dart:ui';

import 'package:flutter/material.dart';

enum ScreenType {
  desktop,
  tablet,
  phone,
}
typedef ResponsiveWidgetBuilder = Widget Function(BuildContext, ScreenType);

class Responsive extends StatefulWidget {
  const Responsive({Key key, this.builder}) : super(key: key);

  final ResponsiveWidgetBuilder builder;

  @override
  _ResponsiveState createState() => _ResponsiveState();
}

class _ResponsiveState extends State<Responsive> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    print('object');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(' Build');
    return OrientationBuilder(
      builder: (_, Orientation orientation) {
        final Size size = window.physicalSize / window.devicePixelRatio;
        print(window.devicePixelRatio);
        if (size.width < 500) {
          return widget.builder(_, ScreenType.phone);
        } else if (size.width > 600) {
          return widget.builder(_, ScreenType.desktop);
        } else {
          return widget.builder(_, ScreenType.tablet);
        }
      },
    );
  }
}
