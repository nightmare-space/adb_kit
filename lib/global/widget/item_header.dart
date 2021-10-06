import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class ItemHeader extends StatelessWidget {
  const ItemHeader({Key key, this.color}) : super(key: key);
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          right: Dimens.gap_dp6,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4.w)
        ),
        width: Dimens.gap_dp4,
        height: Dimens.gap_dp16,
      ),
    );
  }
}
