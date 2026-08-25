import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/theme_extensions.dart';
import '../../../../core/utils/widget_utils.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/icon_disc.dart';

/// A titled, rounded card grouping a set of [CustomTile]s (the iOS-style
/// grouped-list section used across the Settings screen).
class CustomSection extends StatelessWidget {
  const CustomSection({super.key, required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTitle(title: title),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: context.cardColor,
          ),
          child: Column(
            children: children,
          ),
        )
      ],
    );
  }
}

/// The section header label above a [CustomSection] card.
class CustomTitle extends StatelessWidget {
  const CustomTitle({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        addHorizontalSpace(16.w),
        AppText(
          text: title,
          color: context.secondaryTextColor,
        ),
      ],
    );
  }
}

/// A single settings row: tinted leading icon disc, title, and either a custom
/// [trailing] (e.g. a switch) or a chevron. Set [destructive] for red styling
/// and [showChevron] to false for action rows that open a dialog.
class CustomTile extends StatelessWidget {
  const CustomTile({
    super.key,
    required this.title,
    required this.onPressed,
    this.trailing,
    this.destructive = false,
    this.enabled = true,
    this.showChevron = true,
    this.icon = Icons.language,
  });

  final String title;
  final Widget? trailing;
  final bool destructive;
  final bool enabled;
  final bool showChevron;
  final IconData icon;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final accent = destructive ? AppColors.error : context.secondaryTextColor;
    final titleColor = !enabled
        ? context.hintColor
        : (destructive ? AppColors.error : context.primaryTextColor);
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        horizontalTitleGap: 12.w,
        leading: AppIconDisc(icon: icon, color: accent),
        title: AppText(
          text: title,
          size: 15,
          weight: FontWeight.w500,
          color: titleColor,
        ),
        trailing: trailing ??
            (showChevron
                ? Icon(
                    Icons.chevron_right_rounded,
                    size: 22.sp,
                    color: context.hintColor,
                  )
                : null),
        onTap: onPressed,
      ),
    );
  }
}
