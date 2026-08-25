import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/theme/app_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.bgColor,
    this.textColor = kWhiteColor,
    this.width,
    this.hight,
    this.icon,
    this.isLoading = false,
    this.fontWeight = FontWeight.normal,
    this.radius = 20.0,
  }) : super(key: key);

  final String text;
  final Function() onPressed;
  final Color bgColor;
  final Color textColor;
  final Widget? icon;
  final double? width;
  final double? hight;
  final bool isLoading;
  final FontWeight fontWeight;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 300.w,
      height: hight ?? 40.h,
      child: ElevatedButton(
        key: key,
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
          backgroundColor: WidgetStateProperty.all<Color>(bgColor),
          // Explicit press/hover splash so the tap feedback is visible (the
          // all-states backgroundColor above otherwise leaves nothing to show).
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withValues(alpha: 0.20);
            }
            if (states.contains(WidgetState.hovered)) {
              return Colors.white.withValues(alpha: 0.10);
            }
            return null;
          }),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius.r),
            ),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(5),
                child: Center(
                    child: SizedBox(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  icon ?? const SizedBox(),
                  if (icon != null) SizedBox(width: 6.w),
                  AppText(
                    text: text,
                    size: 16,
                    color: textColor,
                    weight: fontWeight,
                  ),
                  const Spacer(),
                ],
              ),
      ),
    );
  }
}
