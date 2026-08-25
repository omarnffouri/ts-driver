import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';

import 'register_field.dart';

/// Read-only [RegisterField] that opens the theme-aware date picker on tap and
/// writes the picked date back as MM-dd-yyyy. Inherits the app theme so the
/// dialog renders correctly in dark mode (no forced light scheme).
class RegisterDateField extends StatelessWidget {
  const RegisterDateField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = 'Select date',
    this.icon = Icons.calendar_month_rounded,
    this.isRequired = true,
    this.validatorMsg,
    this.initialDate,
    this.firstDate,
    this.lastDate,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isRequired;
  final String? validatorMsg;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    return RegisterField(
      controller: controller,
      label: label,
      hint: hint,
      icon: icon,
      isRequired: isRequired,
      validatorMsg: validatorMsg ?? 'Please select a date',
      readOnly: true,
      onTap: () async {
        FocusScope.of(context).unfocus();
        final picked = await showAppDatePicker(
          context,
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate,
        );
        if (picked != null) {
          controller.text = DateFormat('MM-dd-yyyy').format(picked);
        }
      },
    );
  }
}
