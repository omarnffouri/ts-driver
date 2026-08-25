import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/field_error_text.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

/// One BOL photo category: an icon-chip header with a live count badge and a
/// required/optional pill, then a horizontal strip of captured photos ending in
/// an add tile — or a teaching empty state. Modeled on the inspection
/// `DamageSideCard`; the add callback receives the strip's [ScrollController] so
/// the caller can keep it scrolled to the newest photo.
class BolCategoryCard extends StatefulWidget {
  const BolCategoryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.files,
    required this.maxFiles,
    required this.emptyHint,
    required this.onAdd,
    required this.onRemove,
    this.isRequired = false,
    this.error,
  });

  final IconData icon;
  final String label;
  final RxList<File> files;
  final int maxFiles;
  final String emptyHint;
  final void Function(ScrollController scroll) onAdd;
  final void Function(int index) onRemove;
  final bool isRequired;
  final RxnString? error;

  @override
  State<BolCategoryCard> createState() => _BolCategoryCardState();
}

class _BolCategoryCardState extends State<BolCategoryCard> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = widget.files.length;
      final full = count >= widget.maxFiles;
      final hasError = widget.error?.value != null;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: hasError ? AppColors.error : context.dividerColor,
            width: hasError ? 1.4 : 1,
          ),
          boxShadow: context.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _iconChip(context),
                SizedBox(width: 10.w),
                AppText(
                  text: widget.label,
                  maxLines: 1,
                  size: 13.5,
                  weight: FontWeight.w700,
                  color: context.strongTextColor,
                ),
                if (count > 0) ...[
                  SizedBox(width: 8.w),
                  _countBadge(context, count, full),
                ],
                const Spacer(),
                _requirementPill(context),
              ],
            ),
            SizedBox(height: 14.h),
            count == 0 ? _emptyState(context) : _photoStrip(context, full),
            if (hasError) FieldErrorText(widget.error!.value!),
          ],
        ),
      );
    });
  }

  Widget _iconChip(BuildContext context) {
    return Container(
      width: 34.r,
      height: 34.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.primaryTint,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(widget.icon, size: 19.r, color: AppColors.primary),
    );
  }

  Widget _countBadge(BuildContext context, int count, bool full) {
    final color = full ? context.successTextColor : AppColors.primary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: full
            ? context.successTextColor.applyOpacity(.14)
            : context.primaryTint,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (full) ...[
            Icon(Icons.check_rounded, size: 11.w, color: color),
            SizedBox(width: 2.w),
          ],
          AppText(
            text: '$count/${widget.maxFiles}',
            size: 10.5,
            weight: FontWeight.w700,
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _requirementPill(BuildContext context) {
    final required = widget.isRequired;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: required ? context.errorSurfaceColor : context.inputFillColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: AppText(
        text: required ? 'Required' : 'Optional',
        size: 10,
        weight: required ? FontWeight.w700 : FontWeight.w600,
        color: required ? AppColors.error : context.hintColor,
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Row(
      children: [
        Icon(
          widget.isRequired
              ? Icons.photo_camera_outlined
              : Icons.add_a_photo_outlined,
          size: 18.w,
          color: context.hintColor,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: AppText(
            text: widget.emptyHint,
            size: 12,
            maxLines: 2,
            color: context.secondaryTextColor,
          ),
        ),
        SizedBox(width: 8.w),
        _addTile(context),
      ],
    );
  }

  Widget _photoStrip(BuildContext context, bool full) {
    final count = widget.files.length;
    return SizedBox(
      height: 70.h,
      child: ListView.builder(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.only(top: 6.h, right: 6.w),
        itemCount: full ? count : count + 1,
        itemBuilder: (context, index) {
          if (!full && index == count) return _addTile(context);
          return Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: _thumb(context, widget.files[index], index),
          );
        },
      ),
    );
  }

  Widget _thumb(BuildContext context, File file, int index) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: context.dividerColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.file(
              file,
              width: 64.w,
              height: 64.w,
              fit: BoxFit.cover,
              cacheWidth: 192,
            ),
          ),
        ),
        Positioned(
          top: -6.h,
          right: -6.w,
          child: GestureDetector(
            onTap: () => widget.onRemove(index),
            child: Container(
              width: 20.w,
              height: 20.w,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded,
                  size: 14.w, color: AppColors.onPrimary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addTile(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onAdd(_scroll),
      child: Container(
        width: 64.w,
        height: 64.w,
        decoration: BoxDecoration(
          color: context.inputFillColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: context.dividerColor, width: 1.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_rounded,
                size: 22.w, color: AppColors.primary),
            SizedBox(height: 2.h),
            const AppText(
              text: 'Add',
              size: 10,
              weight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
