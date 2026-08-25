import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/core/gen/fonts.gen.dart';
import 'package:ts_driver/app/core/utils/input_utils.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

/// Shared rounded outline border for register inputs (field + dropdown search).
OutlineInputBorder registerFieldBorder(Color color, double width) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: color, width: width),
    );

/// Token-themed register form field: a label above a soft-filled rounded input
/// with a leading icon that flips to brand red on focus. Replaces the legacy
/// outlined CustomTextFieldWidget styling within the register flow.
class RegisterField extends StatelessWidget {
  const RegisterField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.isRequired = true,
    this.validatorMsg,
    this.keyboardType,
    this.formatters,
    this.suffix,
    this.readOnly = false,
    this.obscure = false,
    this.onChanged,
    this.onTap,
    this.maxLines = 1,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final bool isRequired;
  final String? validatorMsg;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final Widget? suffix;
  final bool readOnly;
  final bool obscure;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final int maxLines;
  final TextInputAction textInputAction;

  String? _validate(String? value) {
    if (!isRequired) return null;
    final v = value ?? '';
    if (keyboardType == TextInputType.emailAddress) {
      if (v.isEmpty) return validatorMsg ?? 'Required';
      return emailInputValidator(v) ? null : 'Enter a valid email address';
    }
    return v.isEmpty ? (validatorMsg ?? 'Required') : null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegisterFieldLabel(label: label, isRequired: isRequired),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: formatters,
          onChanged: onChanged,
          onTap: onTap,
          readOnly: readOnly,
          obscureText: obscure,
          maxLines: obscure ? 1 : maxLines,
          validator: _validate,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          style: TextStyle(
            fontFamily: FontFamily.poppins,
            fontSize: 14.sp,
            overflow: TextOverflow.ellipsis,
            color: readOnly
                ? context.secondaryTextColor
                : context.primaryTextColor,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: context.inputFillColor,
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: FontFamily.poppins,
              fontSize: 13.sp,
              color: context.hintColor,
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            prefixIcon: icon == null ? null : Icon(icon, size: 20.w),
            prefixIconColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.error)) {
                return AppColors.error;
              }
              if (states.contains(WidgetState.focused)) {
                return AppColors.primary;
              }
              return AppColors.mutedPrimary;
            }),
            suffixIcon: suffix,
            errorStyle: TextStyle(fontSize: 11.sp, color: AppColors.error),
            border: registerFieldBorder(context.dividerColor, 1),
            enabledBorder: registerFieldBorder(context.dividerColor, 1),
            focusedBorder: registerFieldBorder(AppColors.primary, 1.5),
            errorBorder: registerFieldBorder(AppColors.error, 1),
            focusedErrorBorder: registerFieldBorder(AppColors.error, 1.5),
          ),
        ),
      ],
    );
  }
}

/// Field label with an optional brand-red required asterisk. Shared by every
/// register input atom so the asterisk is never baked into label strings.
class RegisterFieldLabel extends StatelessWidget {
  const RegisterFieldLabel({
    super.key,
    required this.label,
    this.isRequired = true,
  });

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w),
      child: Text.rich(
        TextSpan(
          text: label,
          style: TextStyle(
            fontFamily: FontFamily.poppins,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: context.secondaryTextColor,
          ),
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
