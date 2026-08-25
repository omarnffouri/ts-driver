import 'package:flutter/material.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';
import 'package:ts_driver/app/theme/app_colors.dart';

void showErrorDialog(String message) {
  statusDialog(
    badgeColor: AppColors.error,
    icon: Icons.error_outline_rounded,
    title: message,
    titleSize: 16,
    message: 'Please contact the admin',
    barrierDismissible: false,
  );
}
