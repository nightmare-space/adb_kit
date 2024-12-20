import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:get/get.dart';

class Menu extends StatefulWidget {
  const Menu({super.key, required this.offset});
  final Offset offset;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: widget.offset.dx - 140.w - 16.w,
            top: widget.offset.dy,
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Container(
                  width: 140.w,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Theme.of(context).colorScheme.surface,
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(10.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            Get.back(result: 0);
                            showToast('快了');
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.w),
                            child: SizedBox(
                              width: double.infinity,
                              child: Center(
                                child: Text('安卓应用'),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.back(result: 0);
                            showToast('快了');
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.w),
                            child: SizedBox(
                              width: double.infinity,
                              child: Center(
                                child: Text('其它进程'),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.back(result: 0);
                            showToast('快了');
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.w),
                            child: SizedBox(
                              width: double.infinity,
                              child: Center(
                                child: Text('所有进程'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
