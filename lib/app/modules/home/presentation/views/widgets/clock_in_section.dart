import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_loading_wrapper_widget.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';
import 'package:ts_driver/app/modules/home/presentation/controllers/home_controller.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

/// The clock-in/out area on the home header: the live duration (D/H/M/S) and
/// the clock-in/out button. Hidden until the driver is hired.
class ClockInSection extends GetView<HomeController> {
  const ClockInSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Visibility(
        visible: !controller.hideClockSection.value,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _ClockTimer(),
            _ClockButton(),
          ],
        ),
      ),
    );
  }
}

class _ClockTimer extends GetView<HomeController> {
  const _ClockTimer();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => LoadingWrapperWidget(
        isLoading: controller.isCheckingClockIn,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _ClockUnit(value: controller.days.value, unit: "Days"),
            const SizedBox(width: 6),
            _ClockUnit(value: controller.hours.value, unit: "Hours"),
            const SizedBox(width: 6),
            _ClockUnit(value: controller.minutes.value, unit: "Min"),
            const SizedBox(width: 6),
            _ClockUnit(value: controller.seconds.value, unit: "Sec"),
          ],
        ),
      ),
    );
  }
}

class _ClockButton extends GetView<HomeController> {
  const _ClockButton();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isCheckingClockIn || controller.isClockingInOut) {
        return LoadingWrapperWidget(
          isLoading: true,
          baseColor: AppColors.onColoredShimmerBase,
          highlightColor: AppColors.onColoredShimmerHighlight,
          child: Container(
            width: 120.w,
            height: 38.h,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(30.r),
            ),
          ),
        );
      }

      if (controller.isCheckingClockInFailed) {
        return _ClockPill(
          onTap: controller.refeshClockInState,
          icon: Icons.refresh_rounded,
          label: "Refresh",
          color: AppColors.info,
        );
      }

      final clockedIn = controller.isClockedIn;
      return _ClockPill(
        onTap: () {
          if (controller.currentState.value.id! < 5) {
            CommonWidgets.showSnackBar(
              title: 'Error'.tr,
              message: "Please complete your profile first",
            );
            return;
          }
          controller.onClockInOutClicked();
        },
        svgAsset: Assets.svg.clockIcon,
        label: clockedIn ? "Clock-Out" : "Clock-In",
        color: clockedIn ? AppColors.primary : AppColors.success,
      );
    });
  }
}

class _ClockPill extends StatelessWidget {
  const _ClockPill({
    required this.onTap,
    required this.label,
    required this.color,
    this.icon,
    this.svgAsset,
  });

  final VoidCallback onTap;
  final String label;
  final Color color;
  final IconData? icon;
  final String? svgAsset;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.applyOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (svgAsset != null)
              SvgPicture.asset(
                svgAsset!,
                width: 18.w,
                height: 18.w,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              )
            else if (icon != null)
              Icon(icon, size: 18.w, color: color),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClockUnit extends StatelessWidget {
  const _ClockUnit({required this.value, required this.unit});

  final int value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final color = value > 0 ? Colors.white : Colors.white.applyOpacity(0.7);
    return SizedBox(
      height: 50,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.toString(),
              style: Get.theme.textTheme.headlineSmall?.copyWith(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            addVerticalSpace(4),
            Text(
              unit,
              style: Get.theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
