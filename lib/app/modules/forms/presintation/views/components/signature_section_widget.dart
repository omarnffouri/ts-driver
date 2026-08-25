import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signature/signature.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

/// The signature capture step: a card that reads as the last field of the form
/// (same surface/border tokens as the text fields) wrapping the writing panel.
/// The panel + on-screen ink follow the theme (light/black vs dark/off-white),
/// while the exported PNG stays black-on-light — see [AppColors.darkSignatureInk].
class SignatureSectionWidget extends StatelessWidget {
  final SignatureController controller;

  const SignatureSectionWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.dividerColor),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RichText(
                text: TextSpan(
                  text: 'Signature',
                  style: TextStyle(
                    color: context.primaryTextColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.error, fontSize: 15.sp),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Rebuilds on every stroke — SignatureController is a ValueNotifier.
              AnimatedBuilder(
                animation: controller,
                builder: (_, __) {
                  final empty = controller.isEmpty;
                  return TextButton.icon(
                    onPressed: empty ? null : controller.clear,
                    icon: Icon(Icons.refresh_rounded, size: 16.w),
                    label: Text('Clear', style: TextStyle(fontSize: 13.sp)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      disabledForegroundColor: context.hintColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            height: 100.h,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: context.signaturePanelColor,
              borderRadius: BorderRadius.circular(12.r),
              // Defines the writing area against the card — essential in light
              // mode, where panel and card are both near-white.
              border: Border.all(color: context.dividerColor),
            ),
            child: Stack(
              children: [
                // Empty-state guide painted UNDER the strokes; it fades out on
                // first stroke and never reaches the exported bytes.
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (_, __) => IgnorePointer(
                      child: AnimatedOpacity(
                        opacity: controller.isEmpty ? 1 : 0,
                        duration: const Duration(milliseconds: 180),
                        child: const _SignHereGuide(),
                      ),
                    ),
                  ),
                ),
                Signature(
                  controller: controller,
                  // Transparent so the guide painted underneath shows through;
                  // the panel surface comes from the wrapping Container.
                  backgroundColor: Colors.transparent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SignHereGuide extends StatelessWidget {
  const _SignHereGuide();

  @override
  Widget build(BuildContext context) {
    final guide = context.hintColor;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sign here',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: guide),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(Icons.close_rounded,
                  size: 14.w, color: guide.withValues(alpha: 0.55)),
              SizedBox(width: 6.w),
              Expanded(
                child: Container(
                  height: 1,
                  color: guide.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
