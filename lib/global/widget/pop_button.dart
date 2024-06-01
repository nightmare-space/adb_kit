import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class PopButton extends StatelessWidget {
  const PopButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
        height: 36.w,
        width: 36.w,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 18.w,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
