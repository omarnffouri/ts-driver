import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/count_pill.dart';
import 'package:ts_driver/app/modules/home/presentation/controllers/home_controller.dart';

class HomeTabBar extends GetView<HomeController> {
  const HomeTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.currentSelection.value;
      return Row(
        children: [
          _HeaderTab(
            selected: selected == 0,
            onTap: () => controller.currentSelection.value = 0,
            clipRadius: selected == 1
                ? BorderRadius.only(topLeft: Radius.circular(15.r))
                : const BorderRadius.only(),
            containerRadius: BorderRadius.only(
              topLeft: Radius.circular(15.r),
              bottomRight: Radius.circular(15.r),
            ),
            child: AppText(
              text: controller.isHired ? "Announcement" : 'Application Status',
              size: 12,
              weight: FontWeight.bold,
              color: selected == 0
                  ? context.primaryTextColor
                  : context.secondaryTextColor,
            ),
          ),
          _HeaderTab(
            selected: selected == 1,
            onTap: () => controller.currentSelection.value = 1,
            clipRadius: const BorderRadius.only(),
            containerRadius: BorderRadius.only(
              topRight: Radius.circular(15.r),
              bottomLeft: Radius.circular(15.r),
            ),
            child: _DocumentRequestsLabel(
              // Hidden while the tab is open — its body already shows the count.
              count: selected == 1 ? 0 : controller.pendingDocumentsCount,
              color: selected == 1
                  ? context.primaryTextColor
                  : context.secondaryTextColor,
            ),
          ),
        ],
      );
    });
  }
}

class _HeaderTab extends StatelessWidget {
  const _HeaderTab({
    required this.selected,
    required this.onTap,
    required this.clipRadius,
    required this.containerRadius,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final BorderRadius clipRadius;
  final BorderRadius containerRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: clipRadius,
        child: Container(
          decoration: BoxDecoration(
            // Selected tab inherits the card surface; unselected sits recessed.
            color: selected ? Colors.transparent : context.backgroundColor,
            borderRadius: containerRadius,
          ),
          child: TextButton(
            onPressed: onTap,
            style: ButtonStyle(
              overlayColor: WidgetStateProperty.all(Colors.transparent),
            ),
            child: SizedBox(height: 22.h, child: child),
          ),
        ),
      ),
    );
  }
}

class _DocumentRequestsLabel extends StatelessWidget {
  const _DocumentRequestsLabel({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: AppText(
            text: 'Document Requests',
            size: 12,
            maxLines: 1,
            weight: FontWeight.bold,
            color: color,
          ),
        ),
        if (count > 0)
          Padding(
            padding: EdgeInsets.only(left: 6.w),
            child: CountPill(count: count),
          ),
      ],
    );
  }
}
