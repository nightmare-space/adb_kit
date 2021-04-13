import 'package:adb_tool/config/dimens.dart';
import 'package:flutter/material.dart';

class NiIconButton extends StatelessWidget {
  const NiIconButton({Key key, this.child, this.onTap}) : super(key: key);
  final Widget child;
  final GestureTapCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: Dimens.gap_dp48,
        height: Dimens.gap_dp48,
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimens.gap_dp24),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(Dimens.gap_dp12),
            child: child,
          ),
        ),
      ),
    );
  }
}
