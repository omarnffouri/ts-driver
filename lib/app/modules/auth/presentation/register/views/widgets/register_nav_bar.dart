import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

/// Step navigation row: a clean white Back (← left arrow) and a brand-red
/// Next/Accept (→ trailing arrow). When [showBack] is false the Next fills the
/// width.
class RegisterNavBar extends StatelessWidget {
  const RegisterNavBar({
    super.key,
    required this.onNext,
    this.onBack,
    this.nextText = 'Next',
    this.backText = 'Back',
    this.showBack = true,
    this.isLoading = false,
    this.enabled = true,
  });

  final VoidCallback onNext;
  final VoidCallback? onBack;
  final String nextText;
  final String backText;
  final bool showBack;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final next = _NavButton(
      label: nextText,
      icon: Icons.arrow_forward_rounded,
      iconTrailing: true,
      bg: AppColors.primary,
      fg: AppColors.onPrimary,
      shadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: .35),
          blurRadius: 16.r,
          offset: Offset(0, 6.h),
        ),
      ],
      isLoading: isLoading,
      enabled: enabled,
      onTap: onNext,
    );

    if (!showBack) return SizedBox(width: double.infinity, child: next);

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _NavButton(
            label: backText,
            icon: Icons.arrow_back_rounded,
            iconTrailing: false,
            bg: context.cardColor,
            fg: context.primaryTextColor,
            border: context.dividerColor,
            shadow: context.cardShadow,
            onTap: onBack ?? () {},
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(flex: 2, child: next),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    required this.iconTrailing,
    required this.bg,
    required this.fg,
    required this.onTap,
    this.border,
    this.shadow,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final bool iconTrailing;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;
  final Color? border;
  final List<BoxShadow>? shadow;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, size: 18.w, color: fg);
    final content = isLoading
        ? SizedBox(
            width: 20.w,
            height: 20.w,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!iconTrailing) ...[iconWidget, SizedBox(width: 8.w)],
              AppText(
                text: label,
                size: 16,
                weight: FontWeight.w600,
                color: fg,
              ),
              if (iconTrailing) ...[SizedBox(width: 8.w), iconWidget],
            ],
          );

    Widget button = DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
        border: border == null ? null : Border.all(color: border!),
        boxShadow: shadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: isLoading ? null : onTap,
          child: SizedBox(height: 50.h, child: Center(child: content)),
        ),
      ),
    );

    if (!enabled) {
      button = Opacity(opacity: .5, child: AbsorbPointer(child: button));
    }
    return button;
  }
}
