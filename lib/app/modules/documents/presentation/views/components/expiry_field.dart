import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/widget_utils.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/theme_extensions.dart';
import '../../controllers/documents_controller.dart';

class ExpiryField extends StatelessWidget {
  const ExpiryField({super.key, required this.index});

  final int index;

  Future<void> _pick(BuildContext context) async {
    final picked = await showAppDatePicker(
      context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      Get.find<DocumentsController>()
          .setExpiDate(index, DateFormat('MM-dd-yyyy').format(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentsController>();
    return Obx(() {
      final date = controller.expiryDateOf(index);
      final hasDate = date != null;
      return GestureDetector(
        onTap: () => _pick(context),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
          decoration: BoxDecoration(
            color: hasDate ? context.primaryTint : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: hasDate
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : context.dividerColor,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.event_outlined,
                size: 16.w,
                color: hasDate ? AppColors.primary : context.secondaryTextColor,
              ),
              addHorizontalSpace(8.w),
              Expanded(
                child: AppText(
                  text: hasDate ? 'Expires $date' : 'Set expiry date',
                  size: 12,
                  weight: FontWeight.w600,
                  color:
                      hasDate ? AppColors.primary : context.secondaryTextColor,
                ),
              ),
              Icon(
                hasDate
                    ? Icons.check_circle_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 16.w,
                color: hasDate ? AppColors.primary : context.hintColor,
              ),
            ],
          ),
        ),
      );
    });
  }
}
