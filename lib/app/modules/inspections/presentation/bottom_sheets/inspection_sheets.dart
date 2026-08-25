import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/gen/fonts.gen.dart';
import '../../domain/entities/inspection_damage.dart';
import '../../../../core/utils/widget_utils.dart';
import '../../../../core/widgets/app_botton.dart';
import '../../../../core/widgets/app_text.dart';
import '../../domain/entities/inspection_options_entity.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/theme_extensions.dart';

/// Themed bottom-sheet building blocks + flows shared by the trailer and truck
/// inspection controllers, so both screens get the same sheets.

/// Neutral sheet header: bold title + a close icon (or a text action like "Done").
Widget inspectionSheetHeader(
  BuildContext context,
  String title, {
  String? actionText,
}) {
  return Padding(
    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
    child: Row(
      children: [
        Expanded(
          child: AppText(
            text: title,
            size: 16,
            weight: FontWeight.w700,
            color: context.strongTextColor,
          ),
        ),
        GestureDetector(
          onTap: () => Get.back(),
          child: actionText != null
              ? AppText(
                  text: actionText,
                  size: 14,
                  weight: FontWeight.w700,
                  color: AppColors.primary,
                )
              : Icon(Icons.close_rounded, size: 22.w, color: context.hintColor),
        ),
      ],
    ),
  );
}

/// A full-width selectable row: tinted + checked when [selected].
Widget inspectionSelectableOption(
  BuildContext context, {
  required String label,
  required bool selected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: selected ? context.primaryTint : context.inputFillColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: selected ? AppColors.primary : context.dividerColor,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              text: label,
              size: 14,
              weight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? AppColors.primary : context.primaryTextColor,
            ),
          ),
          if (selected)
            Icon(Icons.check_rounded, size: 20.w, color: AppColors.primary),
        ],
      ),
    ),
  );
}

/// Single-select list sheet (oil / fuel status). Closes on selection.
void showSelectionSheet({
  required String title,
  required List<String> options,
  required String selected,
  required void Function(String value) onSelect,
}) {
  final ctx = Get.context!;
  showAppBottomSheet(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        inspectionSheetHeader(ctx, title),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: options
                .map((o) => inspectionSelectableOption(
                      ctx,
                      label: o,
                      selected: o == selected,
                      onTap: () {
                        onSelect(o);
                        Get.back();
                      },
                    ))
                .toList(),
          ),
        ),
        SizedBox(height: 12.h),
      ],
    ),
  );
}

/// The captured-damages list for one side: tap a row to change its category,
/// the ✕ removes it, the button adds another.
void showDamagesListSheet({
  required RxList<InspectionDamage> damages,
  required VoidCallback onAdd,
  required void Function(int index) onRemove,
  required void Function(int index) onChangeType,
}) {
  final ctx = Get.context!;
  showAppBottomSheet(
    child: SizedBox(
      height: Get.height * 0.8,
      child: Column(
        children: [
          inspectionSheetHeader(ctx, 'Damages', actionText: 'Done'),
          Expanded(
            child: Obx(
              () => damages.isEmpty
                  ? _damagesEmpty(ctx)
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: damages.length,
                      itemBuilder: (_, index) => _damageListTile(
                        ctx,
                        damages[index],
                        () => onChangeType(index),
                        () => onRemove(index),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: AppButton(
              text: 'Add Damage',
              bgColor: AppColors.primary,
              width: double.infinity,
              hight: 50.h,
              radius: 14,
              fontWeight: FontWeight.bold,
              icon: Icon(Icons.add_a_photo_rounded,
                  color: AppColors.onPrimary, size: 18.w),
              onPressed: onAdd,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _damagesEmpty(BuildContext context) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.photo_camera_outlined, size: 40.w, color: context.hintColor),
        SizedBox(height: 10.h),
        AppText(
          text: 'No damages added yet',
          size: 13,
          color: context.secondaryTextColor,
        ),
      ],
    ),
  );
}

Widget _damageListTile(
  BuildContext context,
  InspectionDamage item,
  VoidCallback onChangeType,
  VoidCallback onRemove,
) {
  return GestureDetector(
    onTap: onChangeType,
    child: Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: context.inputFillColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.file(item.image,
                width: 48.w, height: 48.w, fit: BoxFit.cover, cacheWidth: 144),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: item.damage,
                  size: 14,
                  weight: FontWeight.w600,
                  color: context.primaryTextColor,
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Icon(Icons.edit_outlined,
                        size: 12.w, color: AppColors.primary),
                    SizedBox(width: 4.w),
                    const AppText(
                      text: 'Tap to change type',
                      size: 11,
                      weight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 26.w,
              height: 26.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.primaryTint,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded,
                  size: 16.w, color: AppColors.primary),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Add-damage sheet: photo preview + category dropdown + confirm.
void showAddDamageSheet({
  required File image,
  required Rx<bool> isLoading,
  required Rxn<InspectionOptionResponseEntity> response,
  required VoidCallback onRetry,
  required void Function(InspectionOptionEntity category) onConfirm,
}) {
  final ctx = Get.context!;
  final Rxn<InspectionOptionEntity> selected = Rxn<InspectionOptionEntity>();
  showAppBottomSheet(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        inspectionSheetHeader(ctx, 'Add Damage'),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.file(image,
                width: double.infinity,
                height: 160.h,
                fit: BoxFit.cover,
                cacheHeight: 480),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Obx(() {
            if (isLoading.value) {
              return Padding(
                padding: EdgeInsets.all(8.w),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }
            final categories = response.value?.payload?.categories;
            if (response.value == null) {
              return _optionsError(
                  ctx, 'Unable to load inspection options.', onRetry);
            }
            if (categories == null || categories.isEmpty) {
              return _optionsError(ctx, 'Damage options missing.', onRetry);
            }
            return _damageDropdown(ctx, categories, selected);
          }),
        ),
        SizedBox(height: 16.h),
        Obx(
          () => Padding(
            padding: EdgeInsets.all(16.w),
            child: AppButton(
              text: 'Add Damage',
              bgColor: AppColors.primary,
              width: double.infinity,
              hight: 50.h,
              radius: 14,
              fontWeight: FontWeight.bold,
              icon: Icon(Icons.check_rounded,
                  color: AppColors.onPrimary, size: 18.w),
              onPressed: selected.value == null
                  ? () {}
                  : () {
                      onConfirm(selected.value!);
                      Get.back();
                    },
            ),
          ),
        ),
      ],
    ),
  );
}

/// Re-pick the category for an already-captured photo (no re-shoot).
void showChangeDamageTypeSheet({
  required List<InspectionOptionEntity> categories,
  required InspectionDamage current,
  required void Function(InspectionOptionEntity category) onPick,
}) {
  final ctx = Get.context!;
  showAppBottomSheet(
    child: SizedBox(
      height: Get.height * 0.6,
      child: Column(
        children: [
          inspectionSheetHeader(ctx, 'Damage Type'),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final category = categories[i];
                return inspectionSelectableOption(
                  ctx,
                  label: category.name ?? '',
                  selected: category.id == current.damageId,
                  onTap: () {
                    onPick(category);
                    Get.back();
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _damageDropdown(
  BuildContext context,
  List<InspectionOptionEntity> categories,
  Rxn<InspectionOptionEntity> selected,
) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 14.w),
    decoration: BoxDecoration(
      color: context.inputFillColor,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: context.dividerColor),
    ),
    child: DropdownButtonHideUnderline(
      child: Obx(
        () => DropdownButton<InspectionOptionEntity>(
          isExpanded: true,
          value: selected.value,
          hint: AppText(
            text: 'Select damage category',
            size: 14,
            color: context.hintColor,
          ),
          icon: Icon(Icons.arrow_drop_down_rounded, color: context.hintColor),
          dropdownColor: context.cardColor,
          style: TextStyle(
            fontFamily: FontFamily.poppins,
            color: context.primaryTextColor,
            fontSize: 14.sp,
          ),
          onChanged: (v) {
            if (v != null) selected(v);
          },
          items: categories
              .map(
                (value) => DropdownMenuItem<InspectionOptionEntity>(
                  value: value,
                  child: AppText(
                    text: value.name ?? '',
                    size: 14,
                    color: context.primaryTextColor,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    ),
  );
}

Widget _optionsError(
  BuildContext context,
  String message,
  VoidCallback onRetry,
) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      AppText(
        text: message,
        size: 13,
        weight: FontWeight.w500,
        color: context.warningTextColor,
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 12.h),
      AppButton(
        text: 'Try Again',
        bgColor: AppColors.primary,
        width: 140.w,
        hight: 42.h,
        radius: 12,
        fontWeight: FontWeight.bold,
        onPressed: onRetry,
      ),
    ],
  );
}
