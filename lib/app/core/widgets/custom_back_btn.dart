import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';

class CustomBackBtn extends StatelessWidget {
  const CustomBackBtn({super.key, this.onPressed});
  final Function? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kTransparentColor,
      child: IconButton(
          splashColor: Colors.transparent,
          iconSize: 30.h,
          onPressed: () {
            if (onPressed != null) {
              onPressed!();
            } else {
              Navigator.of(context).pop();
            }
          },
          icon: const Icon(Icons.arrow_back_ios)),
    );
  }
}
