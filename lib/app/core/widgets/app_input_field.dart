import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../theme/theme_extensions.dart';

/// Shared single-line input used across auth forms: theme-aware border + text,
/// optional leading [icon], and an accent focus border.
class AppInputField extends StatelessWidget {
  const AppInputField({
    super.key,
    required this.hintText,
    required this.controller,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  final String hintText;
  final TextEditingController controller;
  final IconData? icon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      style: TextStyle(fontSize: 15.sp, color: context.primaryTextColor),
      decoration: InputDecoration(
        prefixIcon: icon == null
            ? null
            : Icon(icon, color: AppColors.primary, size: 22),
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 15.sp, color: context.hintColor),
        isDense: true,
        contentPadding: EdgeInsets.all(10.w),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: context.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.dividerColor),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
