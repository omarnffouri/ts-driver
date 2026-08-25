import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

import 'selectable_pill.dart';

/// A yes/no question with two segmented pills. [value] is true for "Yes",
/// false for "No". Replaces the legacy red Radio rows.
class YesNoField extends StatelessWidget {
  const YesNoField({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
  });

  final String question;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final pillPadding = EdgeInsets.symmetric(horizontal: 26.w, vertical: 9.h);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: question,
          size: 13,
          weight: FontWeight.w600,
          maxLines: 8,
          color: context.primaryTextColor,
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            RegisterSelectablePill(
              label: 'Yes',
              selected: value == true,
              onTap: () => onChanged(true),
              padding: pillPadding,
            ),
            SizedBox(width: 10.w),
            RegisterSelectablePill(
              label: 'No',
              selected: value == false,
              onTap: () => onChanged(false),
              padding: pillPadding,
            ),
          ],
        ),
      ],
    );
  }
}
