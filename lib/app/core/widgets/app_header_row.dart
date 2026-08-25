import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../theme/app_colors.dart';
import '../utils/widget_utils.dart';
import 'app_text.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    Key? key,
    this.leading,
    this.title,
    this.subTitle,
    this.titleStyle,
    this.subTitleStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  }) : super(key: key);

  final Widget? leading;
  final String? title;
  final String? subTitle;
  final TextStyle? titleStyle;
  final TextStyle? subTitleStyle;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (Get.width > 500) addHorizontalSpace(10.w),
          if (leading != null)
            SizedBox(
              child: leading,
            ),
          addHorizontalSpace(8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (title != null)
                AppText(
                  text: title!,
                  size: 16,
                  color: kTextColor,
                  weight: FontWeight.bold,
                ),
              if (subTitle != null)
                AppText(
                  text: subTitle!,
                  size: 14,
                  color: kTextColor,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
