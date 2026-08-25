import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/theme_extensions.dart';
import '../../../../core/helpers/extensions.dart';
import '../../../../core/helpers/shared_preferences_helper.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/icon_disc.dart';
import '../../controllers/settings_controller.dart';

/// Confirmation dialog for signing out.
void showLogoutDialog(BuildContext context) {
  final controller = Get.find<SettingsController>();
  _showAppDialog(
    context,
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppIconDisc(
          icon: Icons.logout_rounded,
          color: AppColors.error,
          size: 56,
          iconSize: 28,
          circle: true,
        ),
        SizedBox(height: 16.h),
        AppText(
          text: 'Log out?',
          size: 18,
          weight: FontWeight.w700,
          color: context.primaryTextColor,
        ),
        SizedBox(height: 6.h),
        AppText(
          text: "You'll need to sign in again to use the app.",
          size: 13,
          maxLines: 2,
          textAlign: TextAlign.center,
          color: context.secondaryTextColor,
        ),
        SizedBox(height: 22.h),
        Row(
          children: [
            Expanded(
              child: _DialogButton(
                label: 'Cancel',
                onTap: () => Get.back(),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _DialogButton(
                label: 'Logout',
                filled: true,
                color: AppColors.error,
                onTap: () async {
                  await Future.wait([
                    SharedPrefrencesHelper.clearMyDetails(),
                    SharedPrefrencesHelper.clearClockInOutSessionId(),
                    Future<void>.delayed(const Duration(milliseconds: 500)),
                  ]);
                  await controller.logout();
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

/// Destructive confirmation dialog for account deletion. The Delete button is
/// disabled until the user checks the consent box.
void showDeleteAccountDialog(BuildContext context) {
  final controller = Get.find<SettingsController>();
  controller.isChecked.value = false;
  _showAppDialog(
    context,
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppIconDisc(
          icon: Icons.delete_outline_rounded,
          color: AppColors.error,
          size: 56,
          iconSize: 28,
          circle: true,
        ),
        SizedBox(height: 16.h),
        AppText(
          text: 'Delete Account?',
          size: 18,
          weight: FontWeight.w700,
          color: context.primaryTextColor,
        ),
        SizedBox(height: 10.h),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _deleteParagraph(
                  context,
                  'Please be aware that initiating this process will result in your account being scheduled for deletion, which will take effect after a 15-day grace period. This action is irreversible once completed.',
                ),
                SizedBox(height: 10.h),
                _deleteParagraph(
                  context,
                  'During these 15 days, you have the option to reactivate your account simply by logging in. However, if you choose not to do so within this timeframe, your account will be permanently deleted.',
                ),
                SizedBox(height: 10.h),
                _deleteParagraph(
                  context,
                  'As a result, all data associated with your account will be lost and cannot be recovered — you will no longer be able to access this account or its associated services.',
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Obx(
          () => _ConsentCheckbox(
            checked: controller.isChecked.value,
            label:
                'I understand, and I want to proceed with the account deletion.',
            onTap: () => controller.isChecked.toggle(),
          ),
        ),
        SizedBox(height: 18.h),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _DialogButton(
                  label: 'Cancel',
                  onTap: () => Get.back(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _DialogButton(
                  label: 'Delete',
                  filled: true,
                  color: AppColors.error,
                  onTap: controller.isChecked.value
                      ? () {
                          Get.back();
                          controller.deleteAccount();
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _deleteParagraph(BuildContext context, String text) => AppText(
      text: text,
      size: 13,
      height: 1.5,
      color: context.secondaryTextColor,
    );

/// Shared chrome for the settings confirmation dialogs (surface, inset, radius,
/// padding). [child] is the dialog body.
void _showAppDialog(BuildContext context, Widget child) {
  Get.dialog(
    Dialog(
      backgroundColor: context.cardColor,
      insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 18.h),
        child: child,
      ),
    ),
  );
}

/// A dialog action button. Filled (primary/destructive) or neutral outline;
/// a null [onTap] renders a disabled state. When [onTap] returns a Future, the
/// button shows a spinner and blocks repeat taps until it completes.
class _DialogButton extends StatefulWidget {
  const _DialogButton({
    required this.label,
    required this.onTap,
    this.filled = false,
    this.color,
  });

  final String label;
  final FutureOr<void> Function()? onTap;
  final bool filled;
  final Color? color;

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton> {
  bool _loading = false;

  Future<void> _handleTap() async {
    final result = widget.onTap?.call();
    if (result is! Future) return;
    setState(() => _loading = true);
    try {
      await result;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14.r);
    final enabled = widget.onTap != null;
    final Color background;
    final Color foreground;
    Border? border;
    if (!enabled) {
      background = context.primaryTextColor.applyOpacity(0.06);
      foreground = context.hintColor;
    } else if (widget.filled) {
      background = widget.color ?? AppColors.primary;
      foreground = AppColors.onPrimary;
    } else {
      background = context.primaryTextColor.applyOpacity(0.08);
      foreground = context.primaryTextColor;
      border = Border.all(color: context.primaryTextColor.applyOpacity(0.20));
    }
    return InkWell(
      onTap: enabled && !_loading ? _handleTap : null,
      borderRadius: radius,
      child: Ink(
        height: 46.h,
        decoration: BoxDecoration(
          color: background,
          borderRadius: radius,
          border: border,
        ),
        child: Center(
          child: _loading
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: foreground,
                  ),
                )
              : AppText(
                  text: widget.label,
                  size: 14,
                  weight: FontWeight.w600,
                  color: foreground,
                ),
        ),
      ),
    );
  }
}

/// A tappable consent checkbox with a label (used by the delete-account flow).
class _ConsentCheckbox extends StatelessWidget {
  const _ConsentCheckbox({
    required this.checked,
    required this.label,
    required this.onTap,
  });

  final bool checked;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 22.w,
            height: 22.w,
            decoration: BoxDecoration(
              color: checked ? AppColors.error : Colors.transparent,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: checked
                    ? AppColors.error
                    : context.primaryTextColor.applyOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: checked
                ? Icon(Icons.check_rounded,
                    size: 16.sp, color: AppColors.onPrimary)
                : null,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: AppText(
              text: label,
              size: 12,
              weight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
