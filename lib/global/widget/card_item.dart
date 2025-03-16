import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class CardItem extends StatelessWidget {
  const CardItem({
    super.key,
    this.child,
    this.padding,
    this.margin,
  });
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.symmetric(horizontal: 8.w),
      child: Material(
        borderRadius: BorderRadius.circular(12.w),
        clipBehavior: Clip.hardEdge,
        // color: Theme.of(context).colorScheme.surfaceContainerLowest,
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: Padding(
          padding: padding ?? EdgeInsets.all(8.w),
          child: child,
        ),
      ),
    );
  }
}
