import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import '../../controllers/forms_controller.dart';

class FormsStepperWidget extends GetView<FormsController> {
  FormsStepperWidget({super.key});

  final ScrollController _scrollController = ScrollController();
  final RxBool _hasAutoScrolled = false.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading || controller.forms.isEmpty) {
        return const SizedBox.shrink();
      }

      final activeStep = controller.activeStep.value;
      final totalSteps = controller.forms.length;

      final stepKeys = List<GlobalKey>.generate(totalSteps, (_) => GlobalKey());

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_hasAutoScrolled.value) return;

        final key = stepKeys[activeStep];
        if (key.currentContext != null) {
          Scrollable.ensureVisible(
            key.currentContext!,
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeInOut,
            alignment: 0.5,
          );
          _hasAutoScrolled.value = true;
        }
      });

      return SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: List.generate(totalSteps, (index) {
            final isActive = index == activeStep;
            final isCompleted = controller.forms[index].isSigned == true;
            final isLast = index == totalSteps - 1;

            return Row(
              children: [
                _StepItem(
                  key: stepKeys[index],
                  index: index,
                  isActive: isActive,
                  isCompleted: isCompleted,
                ),
                if (!isLast) const _DottedLine(),
              ],
            );
          }),
        ),
      );
    });
  }
}

/// =======================
/// Step capsule widget
/// =======================
class _StepItem extends StatelessWidget {
  final int index;
  final bool isActive;
  final bool isCompleted;

  const _StepItem({
    super.key,
    required this.index,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 56,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.stepPillColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              // Red marks the step awaiting action — a completed one keeps
              // only its green tick.
              color: isActive && !isCompleted
                  ? AppColors.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: context.stepPillTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),

        /// ✅ Completed badge
        if (isCompleted)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

/// =======================
/// Dotted connector
/// =======================
class _DottedLine extends StatelessWidget {
  const _DottedLine();

  @override
  Widget build(BuildContext context) {
    final dash = Container(
      width: 2,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: context.stepConnectorColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(children: List.filled(6, dash)),
    );
  }
}
