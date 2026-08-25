import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';

class DeleteMessageConfirmationDialog extends GetView<ChatDetailController> {
  final Function() onDeleteCalled;
  final Function() onCancelCalled;
  const DeleteMessageConfirmationDialog({
    super.key,
    required this.onDeleteCalled,
    required this.onCancelCalled,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Are you sure?',
          style: theme.textTheme.bodyMedium,
        ),
        SizedBox(height: 20.h),
        Obx(
          () => controller.isDeletingMessage
              ? const SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 5,
                    strokeCap: StrokeCap.round,
                  ),
                )
              : Row(
                  children: [
                    addHorizontalSpace(20),
                    Expanded(
                      child: InkWell(
                        onTap: onDeleteCalled,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.r),
                            color: context.hintColor,
                          ),
                          child: const Center(
                            child: AppText(
                              text: 'Delete',
                              color: AppColors.onPrimary,
                              size: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    addHorizontalSpace(10),
                    Expanded(
                      child: InkWell(
                        onTap: onCancelCalled,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.r),
                            color: AppColors.primary,
                          ),
                          child: const Center(
                            child: AppText(
                              text: 'No',
                              color: AppColors.onPrimary,
                              size: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    addHorizontalSpace(20),
                  ],
                ),
        ),
      ],
    );
  }
}
