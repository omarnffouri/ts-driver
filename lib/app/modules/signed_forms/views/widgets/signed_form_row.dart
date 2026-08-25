import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_text.dart';
import '../../../../theme/theme_extensions.dart';
import '../../../forms/domain/entities/signed_form_entity.dart';
import 'signed_form_chips.dart';

class SignedFormRow extends StatelessWidget {
  const SignedFormRow({
    super.key,
    required this.form,
    this.onTap,
    this.onMore,
  });

  final SignedFormEntity form;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.dividerColor),
        boxShadow: context.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: onTap,
          onLongPress: onMore,
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Row(
              children: [
                Container(
                  height: 48.w,
                  width: 48.w,
                  decoration: BoxDecoration(
                    color: context.dividerColor,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    size: 24.w,
                    color: context.secondaryTextColor,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: form.formName ?? '',
                        maxLines: 2,
                        size: 13,
                        weight: FontWeight.w600,
                        height: 1.2,
                        color: context.primaryTextColor,
                      ),
                      SizedBox(height: 6.h),
                      SignedAtLabel(form.signedAt),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onMore,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: context.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
