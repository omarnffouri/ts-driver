import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/routes/app_pages.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/count_icon_badge.dart';

import '../../controllers/home_controller.dart';

class PendingFormsCard extends GetView<HomeController> {
  const PendingFormsCard({super.key});

  Future<void> _openForms() async {
    await Get.toNamed(Routes.FORMS);
    controller.refreshHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.unsignedFormsCount;
      if (count == 0) return SizedBox(height: 15.h);

      return Card(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 15.h),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _openForms,
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                CountIconBadge(
                  icon: Icons.assignment_outlined,
                  count: count,
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        text: 'Pending forms to sign',
                        size: 15,
                        weight: FontWeight.w700,
                        color: context.primaryTextColor,
                      ),
                      SizedBox(height: 4.h),
                      AppText(
                        text: count == 1
                            ? '1 form awaiting your signature'
                            : '$count forms awaiting your signature',
                        size: 12.5,
                        maxLines: 2,
                        color: context.secondaryTextColor,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.sp,
                  color: context.hintColor,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
