import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import '../../controllers/register_controller.dart';

/// Horizontal icon stepper rendered inside the red header: white circles for
/// done/active (icon tinted brand red), frosted white circles for upcoming,
/// joined by progress connectors. Auto-scrolls to keep the active step in view.
class RegisterStepper extends StatelessWidget {
  final RegisterController controller;

  const RegisterStepper({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.stepIcons.length;
      final index = controller.pageIndex.value;
      return SingleChildScrollView(
        controller: controller.scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(count, (i) {
            final isLast = i == count - 1;
            return Row(
              children: [
                _circle(controller.stepIcons[i],
                    isActive: i == index, isDone: i < index),
                if (!isLast) _connector(done: i < index),
              ],
            );
          }),
        ),
      );
    });
  }

  Widget _circle(
    String iconPath, {
    required bool isActive,
    required bool isDone,
  }) {
    final filled = isActive || isDone;
    Widget inner = Container(
      width: 42.w,
      height: 42.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? Colors.white : Colors.white.withValues(alpha: .16),
      ),
      child: isDone
          ? Icon(Icons.check_rounded, size: 20.w, color: AppColors.primary)
          : Image.asset(
              iconPath,
              width: 20.w,
              height: 20.w,
              color: filled
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: .55),
            ),
    );

    if (isActive) {
      inner = Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border:
              Border.all(color: Colors.white.withValues(alpha: .4), width: 2),
        ),
        child: inner,
      );
    } else {
      inner = Padding(padding: EdgeInsets.all(3.w), child: inner);
    }

    return inner;
  }

  Widget _connector({required bool done}) {
    return Container(
      width: 26.w,
      height: 2.h,
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        color: done ? Colors.white : Colors.white.withValues(alpha: .28),
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }
}
