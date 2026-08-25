import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/theme_extensions.dart';
import '../../controllers/signed_forms_controller.dart';

/// Every InputDecoration border is nulled so the theme's focused underline
/// doesn't leak into the pill.
class SignedFormsSearchBar extends GetView<SignedFormsController> {
  const SignedFormsSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: context.hintColor, size: 22.w),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              maxLines: 1,
              textAlignVertical: TextAlignVertical.center,
              style:
                  TextStyle(color: context.primaryTextColor, fontSize: 14.sp),
              cursorColor: AppColors.primary,
              onChanged: controller.search,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              decoration: InputDecoration(
                isCollapsed: true,
                hintText: 'My Signed Form',
                hintStyle: TextStyle(color: context.hintColor, fontSize: 14.sp),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller.searchController,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () {
                  controller.searchController.clear();
                  controller.search('');
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Icon(
                    Icons.close_rounded,
                    color: context.hintColor,
                    size: 20.w,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ViewToggleButton extends GetView<SignedFormsController> {
  const ViewToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: controller.isGrid.toggle,
          child: SizedBox(
            height: 48.h,
            width: 48.w,
            child: Obx(
              () => Icon(
                controller.isGrid.value
                    ? Icons.view_agenda_outlined
                    : Icons.grid_view_rounded,
                color: AppColors.primary,
                size: 22.w,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
