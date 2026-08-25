import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/modules/profile_details/controllers/profile_details_controller.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

class PersonalInfoCard extends GetView<ProfileDetailsController> {
  const PersonalInfoCard({
    super.key,
    required this.children,
    required this.title,
  });

  final List<Widget> children;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
      padding: EdgeInsets.symmetric(
        vertical: 15.h,
      ),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: context.dividerColor),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              title,
              style: TextStyle(
                color: context.primaryTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          addVerticalSpace(4.h),
          Divider(
            thickness: 1,
            color: context.dividerColor,
          ),
          addVerticalSpace(4.h),
          Column(
            children: children,
          )
        ],
      ),
    );
  }
}

/// ----------------------------------------------------------------
/// --------------------- NEW infoWidget ---------------------------
/// ----------------------------------------------------------------
Widget infoWidget(String title, String? value,
    {bool isUpdateable = false, VoidCallback? onTap}) {
  return Builder(
    builder: (context) {
      final row = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(title,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: context.primaryTextColor,
                  )),
            ),
            Text(value == null || value.isEmpty ? '....' : value,
                style: TextStyle(
                  color: context.secondaryTextColor,
                  overflow: TextOverflow.ellipsis,
                )),
            if (isUpdateable) ...[
              addHorizontalSpace(6.w),
              SvgPicture.asset(
                Assets.svg.edit,
                width: 15.h,
              ),
            ],
          ],
        ),
      );
      if (onTap == null) return row;
      return Material(
        type: MaterialType.transparency,
        child: InkWell(onTap: onTap, child: row),
      );
    },
  );
}
