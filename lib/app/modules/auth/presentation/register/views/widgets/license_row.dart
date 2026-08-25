// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';

class LicenseRowWidget extends StatefulWidget {
  LicenseRowWidget({
    super.key,
    required this.value,
    required this.text,
    this.onChange,
  });

  void Function(bool val)? onChange;
  bool value;
  String text;

  @override
  State<LicenseRowWidget> createState() => _LicenseRowWidgetState();
}

class _LicenseRowWidgetState extends State<LicenseRowWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: widget.text,
          size: 13.sp,
          weight: FontWeight.bold,
        ),
        RadioGroup<bool>(
          groupValue: widget.value,
          onChanged: (bool? val) {
            if (val == null) return;
            setState(() {
              widget.value = val;
            });
            widget.onChange?.call(widget.value);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Radio<bool>(
                value: true,
                activeColor: Colors.red,
              ),
              const AppText(text: 'Yes', size: 15),
              addHorizontalSpace(20.w),
              const Radio<bool>(
                value: false,
                activeColor: Colors.red,
              ),
              const AppText(text: 'No', size: 15),
            ],
          ),
        ),
      ],
    );
  }
}
