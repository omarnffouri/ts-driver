import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'register_field.dart';
import 'selectable_pill.dart';

/// Single-select chip group used for small fixed option sets (CDL type, hauling
/// type). Selected chip is brand red; the rest are soft-filled and bordered.
class SelectableChipGroup extends StatelessWidget {
  const SelectableChipGroup({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.isRequired = true,
  });

  final String label;
  final List<String> options;
  final String? value;
  final ValueChanged<String> onChanged;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegisterFieldLabel(label: label, isRequired: isRequired),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: options
              .map(
                (option) => RegisterSelectablePill(
                  label: option,
                  selected: value == option,
                  onTap: () => onChanged(option),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
