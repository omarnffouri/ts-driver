import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_text.dart';
import '../../../../theme/theme_extensions.dart';
import '../../controllers/signed_forms_controller.dart';

class SignedFormsNoResults extends GetView<SignedFormsController> {
  const SignedFormsNoResults({super.key});

  @override
  Widget build(BuildContext context) {
    final query = controller.searchController.text;
    // Centre within the area above the keyboard (the screen doesn't resize for it).
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 60.w,
                color: context.hintColor,
              ),
              SizedBox(height: 18.h),
              AppText(
                text: 'No matching forms',
                size: 17,
                weight: FontWeight.w700,
                color: context.primaryTextColor,
              ),
              SizedBox(height: 10.h),
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.5,
                    color: context.secondaryTextColor,
                  ),
                  children: [
                    const TextSpan(text: 'Nothing matches '),
                    TextSpan(
                      text: '“$query”',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.primaryTextColor,
                      ),
                    ),
                    const TextSpan(text: '.\nTry a different name.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 22.h),
              _ClearSearchChip(
                onTap: () {
                  controller.searchController.clear();
                  controller.search('');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClearSearchChip extends StatelessWidget {
  const _ClearSearchChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(24.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: context.dividerColor, width: 1.w),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.close_rounded,
                size: 17.w,
                color: context.primaryTextColor,
              ),
              SizedBox(width: 7.w),
              AppText(
                text: 'Clear search',
                size: 13.5,
                weight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
