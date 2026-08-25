import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/widgets/app_botton.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

/// Success dialog shown after a trip is completed. On dismiss it returns to the
/// shipments list — the in-transit flow sits one route deeper than the
/// BOL-rejected flow, so it pops twice.
Future<void> showTripCompletedDialog({required bool isBolRejected}) {
  return Get.dialog(
    _TripCompletedDialog(isBolRejected: isBolRejected),
    barrierDismissible: false,
  );
}

class _TripCompletedDialog extends StatelessWidget {
  const _TripCompletedDialog({required this.isBolRejected});

  final bool isBolRejected;

  void _dismiss() {
    // Close the dialog; the in-transit flow is one route deeper than the
    // BOL-rejected flow, so it also pops back to the shipments list.
    Get.back();
    if (!isBolRejected) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 20.h),
        decoration: BoxDecoration(
          color: context.panelColor,
          borderRadius: BorderRadius.circular(22.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88.r,
              height: 88.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.successTextColor.applyOpacity(.12),
                shape: BoxShape.circle,
              ),
              child: Container(
                width: 56.r,
                height: 56.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.successTextColor,
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(Icons.check_rounded, size: 34.r, color: Colors.white),
              ),
            ),
            SizedBox(height: 16.h),
            AppText(
              text: isBolRejected ? 'BOL re-uploaded' : 'Trip completed!',
              size: 20,
              weight: FontWeight.w800,
              color: context.strongTextColor,
            ),
            SizedBox(height: 8.h),
            AppText(
              text: isBolRejected
                  ? 'Your updated BOL has been submitted successfully.'
                  : 'Your BOL is uploaded and the trip is marked complete.',
              size: 13.5,
              color: context.secondaryTextColor,
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            SizedBox(height: 22.h),
            AppButton(
              text: 'Done',
              bgColor: AppColors.primary,
              width: double.infinity,
              hight: 48,
              radius: 12,
              fontWeight: FontWeight.bold,
              icon: const Icon(Icons.check_circle,
                  color: AppColors.onPrimary, size: 18),
              onPressed: _dismiss,
            ),
          ],
        ),
      ),
    );
  }
}
