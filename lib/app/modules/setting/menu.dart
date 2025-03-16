import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class NiMenyItem extends StatelessWidget {
  const NiMenyItem({
    super.key,
    this.value,
    required this.title,
  });
  final dynamic value;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: InkWell(
          onTap: () {
            Get.back(result: value);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 14.w,
                fontWeight: FontWeight.bold,
                // color: Theme.of(context).textTheme.bodyText1!.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NiMenu extends StatefulWidget {
  const NiMenu({
    super.key,
    required this.items,
    required this.offset,
  });
  final List<NiMenyItem> items;
  final Offset offset;

  static Future<T> show<T>({
    required BuildContext context,
    required List<NiMenyItem> items,
  }) async {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(renderBox.size.center(Offset.zero));
    T resilt = await showDialog(
      context: Get.context!,
      builder: (context) {
        return NiMenu(
          items: items,
          offset: offset,
        );
      },
    );
    return resilt;
  }

  @override
  State<NiMenu> createState() => _NiMenuState();
}

class _NiMenuState extends State<NiMenu> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.back();
      },
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              left: widget.offset.dx,
              top: widget.offset.dy,
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8.w),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: 200.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final item in widget.items) item,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
