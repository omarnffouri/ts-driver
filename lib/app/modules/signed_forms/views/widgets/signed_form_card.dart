import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_text.dart';
import '../../../../theme/theme_extensions.dart';
import '../../../forms/domain/entities/signed_form_entity.dart';
import 'signed_form_chips.dart';

class SignedFormCard extends StatelessWidget {
  const SignedFormCard({
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
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.dividerColor),
        boxShadow: context.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          onLongPress: onMore,
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: context.dividerColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.description_rounded,
                            size: 34.w,
                            color: context.secondaryTextColor,
                          ),
                        ),
                        Positioned(
                            top: 6.h, right: 6.w, child: const PdfBadge()),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                AppText(
                  text: form.formName ?? '',
                  maxLines: 2,
                  size: 12.5,
                  weight: FontWeight.w600,
                  height: 1.2,
                  color: context.primaryTextColor,
                ),
                SizedBox(height: 4.h),
                SignedAtLabel(form.signedAt),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
