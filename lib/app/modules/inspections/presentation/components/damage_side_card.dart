import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../domain/entities/inspection_damage.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/theme_extensions.dart';

/// One side's damage card: the (theme-tinted) side illustration, the side name
/// + per-side count badge, a "select damages" affordance, and a horizontal
/// strip of captured photos ending in an add tile. A side with no damages shows
/// a positive "No damage reported" empty state.
///
/// Controller-agnostic: callbacks receive the card's own [ScrollController] so
/// the caller can keep the strip auto-scrolling to the latest photo.
class DamageSideCard extends StatefulWidget {
  const DamageSideCard({
    super.key,
    required this.label,
    required this.svgPath,
    required this.damages,
    required this.onSelect,
    required this.onAdd,
    required this.onRemove,
  });

  final String label;
  final String svgPath;
  final RxList<InspectionDamage> damages;
  final void Function(ScrollController scroll) onSelect;
  final void Function(ScrollController scroll) onAdd;
  final void Function(int index) onRemove;

  @override
  State<DamageSideCard> createState() => _DamageSideCardState();
}

class _DamageSideCardState extends State<DamageSideCard> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.dividerColor),
        boxShadow: context.cardShadow,
      ),
      child: Obx(() {
        final count = widget.damages.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  widget.svgPath,
                  width: 56.w,
                  colorFilter: ColorFilter.mode(
                    context.secondaryTextColor,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 12.w),
                AppText(
                  text: widget.label,
                  size: 13.5,
                  weight: FontWeight.w700,
                  color: context.strongTextColor,
                ),
                if (count > 0) ...[
                  SizedBox(width: 8.w),
                  _countBadge(context, count),
                ],
                const Spacer(),
                _checklistButton(context),
              ],
            ),
            SizedBox(height: 14.h),
            count == 0 ? _emptyState(context) : _photoStrip(context),
          ],
        );
      }),
    );
  }

  Widget _countBadge(BuildContext context, int count) {
    return Container(
      width: 20.w,
      height: 20.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.primaryTint,
        shape: BoxShape.circle,
      ),
      child: AppText(
        text: '$count',
        size: 10.5,
        weight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );
  }

  Widget _checklistButton(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onSelect(_scroll),
      child: Container(
        width: 40.w,
        height: 40.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.inputFillColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: context.dividerColor),
        ),
        child:
            Icon(Icons.checklist_rounded, size: 22.w, color: AppColors.primary),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check_circle_outline_rounded,
            size: 18.w, color: context.successTextColor),
        SizedBox(width: 8.w),
        Expanded(
          child: AppText(
            text: 'No damage reported',
            size: 12,
            color: context.secondaryTextColor,
          ),
        ),
        _addTile(context),
      ],
    );
  }

  Widget _photoStrip(BuildContext context) {
    return SizedBox(
      height: 92.h,
      child: ListView.builder(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemCount: widget.damages.length + 1,
        itemBuilder: (context, index) {
          if (index == widget.damages.length) {
            return Align(
              alignment: Alignment.topCenter,
              child: _addTile(context),
            );
          }
          return Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: Align(
              alignment: Alignment.topCenter,
              child: _thumb(context, widget.damages[index], index),
            ),
          );
        },
      ),
    );
  }

  Widget _thumb(BuildContext context, InspectionDamage damage, int index) {
    return SizedBox(
      width: 64.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
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
                    damage.image,
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
          ),
          SizedBox(height: 4.h),
          AppText(
            text: damage.damage,
            size: 11,
            weight: FontWeight.w500,
            color: context.secondaryTextColor,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
