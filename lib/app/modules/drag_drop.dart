import 'package:adb_tool/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:global_repository/global_repository.dart';
import 'package:nativeshell/nativeshell.dart';

final customDragData = DragDataKey<Map>('custom-drag-data');
typedef PerformCall = void Function(List<String> paths);

class DropTarget extends StatefulWidget {
  const DropTarget({
    Key key,
    this.onPerform,
    this.onTap,
    this.title,
  }) : super(key: key);
  final void Function() onTap;
  final PerformCall onPerform;
  final String title;
  @override
  State<StatefulWidget> createState() {
    return _DropTargetState();
  }
}

class _DropTargetState extends State<DropTarget> {
  DragEffect pickEffect(Set<DragEffect> allowedEffects) {
    if (allowedEffects.contains(DragEffect.Copy)) {
      return DragEffect.Copy;
    } else if (allowedEffects.contains(DragEffect.Link)) {
      return DragEffect.Link;
    } else {
      return allowedEffects.isNotEmpty ? allowedEffects.first : DragEffect.None;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropRegion(
      onDropOver: (event) async {
        final res = pickEffect(event.info.allowedEffects);
        final data = event.info.data;
        _files = await data.get(DragData.files);
        _uris = await data.get(DragData.uris);
        _customData = await data.get(customDragData);

        return res;
      },
      onDropExit: () {
        setState(() {
          _files = null;
          _uris = null;
          _customData = null;
          dropping = false;
        });
      },
      onDropEnter: () {
        setState(() {
          dropping = true;
        });
      },
      onPerformDrop: (e) {
        widget.onPerform?.call(_files);
        print('Performed drop!');
      },
      child: AnimatedContainer(
        decoration: BoxDecoration(
          color: dropping ? AppColors.inputBorderColor : AppColors.background,
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
                      child: Text(_describeDragData()),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Material(
                          color: AppColors.inputBorderColor,
                          borderRadius: BorderRadius.circular(28.w),
                          child: Container(
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
                          child: Text(widget.title),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  String _describeDragData() {
    final res = StringBuffer();

    for (final f in _files ?? []) {
      res.writeln('$f');
    }
    for (final uri in _uris ?? []) {
      res.writeln('$uri');
    }
    final custom = _customData;
    if (custom != null) {
      if (res.isNotEmpty) {
        res.writeln();
      }
      res.writeln('Custom Data:');
      res.writeln('$custom');
    }
    return res.toString();
  }

  List<Uri> _uris;
  List<String> _files;
  Map _customData;

  bool dropping = false;
}
