import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/enum/job_category.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/utils/rounded_fill_button.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import '../../routes/app_pages.dart';
import 'app_text.dart';
import 'sheet_drag_handle.dart';

Future<bool?> showBottomSheetDialog({
  required BuildContext context,
  required Widget title,
  String? description,
  String? cancelActionText,
  String defaultActionText = 'OK',
}) async {
  JobCategory? selectedCategory;

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.panelColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20.0),
      ),
    ),
    builder: (BuildContext ctx) {
      return StatefulBuilder(builder: (context, setState) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 4.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SheetDragHandle(),
                  SizedBox(height: 16.h),
                  Center(child: title),
                  SizedBox(height: 5.h),
                  if (description != null) Text(description),
                  SizedBox(height: 10.h),
                  // Loop through JobCategory.values
                  Column(
                    children: JobCategory.values.map((category) {
                      return buildCategoryItem(
                        ctx,
                        setState,
                        category: category,
                        imagePath: category.imagePath,
                        isSelected: selectedCategory == category,
                        onSelect: () {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  addVerticalSpace(8),
                  RoundedFillButton(
                    backgroundColor: selectedCategory == null
                        ? AppColors.primary.applyOpacity(0.4)
                        : AppColors.primary,
                    label: "Next",
                    onPressed: () {
                      if (selectedCategory != null) {
                        Navigator.of(ctx).pop(true);
                        Get.toNamed(
                          Routes.REGISTER,
                          arguments: selectedCategory!.apiValue,
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        );
      });
    },
  );
}

Widget buildCategoryItem(
  BuildContext ctx,
  StateSetter setState, {
  required JobCategory category,
  required String imagePath,
  required bool isSelected,
  required VoidCallback onSelect,
}) {
  return GestureDetector(
    onTap: onSelect,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      height: 190.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isSelected ? AppColorsLight.mainColorLight : Colors.transparent,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // FULL overlay with text
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColorsLight.mainColor.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.red.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12)),
                  child: AppText(
                    text: category.displayName,
                    size: 22,
                    color: kWhiteColor,
                    weight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
