import 'package:adb_kit/config/font.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit/themes/app_colors.dart';
import 'package:adb_kit/themes/theme.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

typedef PerformCall = void Function(List<String> paths);

class DropTargetContainer extends StatefulWidget {
  const DropTargetContainer({
    Key? key,
    this.onPerform,
    this.onTap,
    this.title,
  }) : super(key: key);
  final void Function()? onTap;
  final PerformCall? onPerform;
  final String? title;
  @override
  State<StatefulWidget> createState() {
    return _DropTargetContainerState();
  }
}

class _DropTargetContainerState extends State<DropTargetContainer> {
  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) {
        setState(() {});
        final List<String> paths = [];
        for (final XFile file in detail.files) {
          paths.add(file.path);
        }
        Log.d('paths -> $paths');
        widget.onPerform!(paths);
      },
      onDragUpdated: (details) {
        setState(() {
          // offset = details.localPosition;
        });
      },
      onDragEntered: (detail) {
        setState(() {
          dropping = true;
          // offset = detail.localPosition;
        });
      },
      onDragExited: (detail) {
        setState(() {
          dropping = false;
          // offset = null;
        });
      },
      child: AnimatedContainer(
        decoration: BoxDecoration(
          color: dropping ? AppColors.inputBorderColor : colorScheme.surface,
          borderRadius: BorderRadius.circular(8.w),
        ),
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: 8.w,
        ),
        child: ClipRect(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 100),
            child: dropping
                ? Center(
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        fontSize: 14.w,
                        color: AppColors.fontColor,
                      ),
                      child: Text(
                        S.current.releaseToAction,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: bold,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Material(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(28.w),
                          child: SizedBox(
                            width: 54.w,
                            height: 54.w,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(28.w),
                              onTap: () {
                                widget.onTap?.call();
                              },
                              child: Padding(
                                padding: EdgeInsets.all(8.w),
                                child: const Icon(Icons.add),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.w),
                        DefaultTextStyle.merge(
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.w,
                            color: AppColors.fontColor,
                          ),
                          child: Text(widget.title!),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  bool dropping = false;
}
