import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/widget_utils.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/theme_extensions.dart';

class VehicleDocsEmpty extends StatelessWidget {
  const VehicleDocsEmpty({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                constraints.maxHeight.isFinite ? constraints.maxHeight : 0,
          ),
          child: _content(context),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84.w,
              height: 84.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.primaryTint,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38.w, color: AppColors.primary),
            ),
            addVerticalSpace(18.h),
            AppText(
              text: title,
              size: 17,
              weight: FontWeight.w700,
              maxLines: 2,
              textAlign: TextAlign.center,
              color: context.primaryTextColor,
            ),
            if (subtitle != null) ...[
              addVerticalSpace(8.h),
              AppText(
                text: subtitle!,
                size: 13,
                maxLines: 3,
                textAlign: TextAlign.center,
                color: context.secondaryTextColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
