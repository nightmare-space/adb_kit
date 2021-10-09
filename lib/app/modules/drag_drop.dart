import 'package:adb_tool/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:global_repository/src/utils/screen_util.dart';
import 'package:nativeshell/nativeshell.dart';

class DragDropPage extends StatefulWidget {
  const DragDropPage();

  @override
  State<StatefulWidget> createState() {
    return DragDropPageState();
  }
}

final customDragData = DragDataKey<Map>('custom-drag-data');

class DragDropPageState extends State<DragDropPage> {
  @override
  Widget build(BuildContext context) {
    return DropTarget();
  }
}

// class DragSource extends StatelessWidget {
//   final String title;
//   final DragData data;

//   const DragSource({Key key, @required this.title, @required this.data})
//       : super(key: key);

//   void startDrag(BuildContext context) async {
//     final session = await DragSession.beginWithContext(
//         context: context,
//         data: data,
//         allowedEffects: [DragEffect.Copy, DragEffect.Link, DragEffect.Move]);
//     final res = await session.waitForResult();
//     print('Drop result: $res');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return RepaintBoundary(
//       child: Builder(
//         builder: (context) {
//           return _buildInner(context);
//         },
//       ),
//     );
//   }

//   Widget _buildInner(BuildContext context) {
//     return GestureDetector(
//       onPanStart: (e) {
//         startDrag(context);
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//             color: Colors.lightBlueAccent,
//           ),
//         ),
//         child: DefaultTextStyle.merge(
//           style: TextStyle(fontSize: 13),
//           child: Center(child: Text(title)),
//         ),
//       ),
//     );
//   }
// }

class DropTarget extends StatefulWidget {
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
        print('Performed drop!');
      },
      child: AnimatedContainer(
        decoration: BoxDecoration(
          color: dropping ? AppColors.surface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.grey,
          ),
        ),
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: 8.w,
        ),
        child: ClipRect(
          child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: 100),
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
                      child: DefaultTextStyle.merge(
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.w,
                          color: AppColors.fontColor,
                        ),
                        child: const Text('拖放或点击按钮选择一个Apk进行安装'),
                      ),
                    )),
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
