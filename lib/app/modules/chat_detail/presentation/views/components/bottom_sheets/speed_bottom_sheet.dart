import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

class SpeedBottomSheet extends StatelessWidget {
  const SpeedBottomSheet({
    super.key,
    required this.speeds,
    required this.currentSpeed,
    required this.onSelect,
  });

  final List<double> speeds;
  final RxDouble currentSpeed;
  final void Function(double) onSelect;

  String _label(double s) {
    if (s == s.truncateToDouble()) return "${s.toStringAsFixed(0)}x";
    return "${s}x";
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.sheetColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              "Playback Speed",
              style: TextStyle(
                color: context.primaryTextColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: speeds.map((speed) {
                  final isSelected = currentSpeed.value == speed;
                  return GestureDetector(
                    onTap: () => onSelect(speed),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : context.dividerColor.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : context.dividerColor,
                        ),
                      ),
                      child: Text(
                        _label(speed),
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.onPrimary
                              : context.primaryTextColor,
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
