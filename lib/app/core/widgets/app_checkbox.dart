// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../utils/widget_utils.dart';
import 'app_text.dart';

class CustomCheckbox extends StatefulWidget {
  CustomCheckbox(
      {super.key,
      required this.value,
      required this.text,
      this.onChange,
      this.focusNode});

  bool value;
  String text;
  void Function(bool? val)? onChange;
  final FocusNode? focusNode;

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Transform.scale(
              scale: Get.width > 500 ? 2.6 : 1.3,
              child: SizedBox(
                height: 18.h,
                width: 18.w,
                child: Checkbox(
                  activeColor: Colors.green,
                  focusNode: widget.focusNode,
                  side: BorderSide(
                    color: Colors.grey,
                    width: 0.5.w,
                  ),
                  value: widget.value,
                  onChanged: (bool? value) {
                    setState(() {});
                    if (widget.onChange != null) {
                      widget.onChange!(value);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        addHorizontalSpace(8),
        Expanded(
          child: AppText(
            text: widget.text,
            size: 12,
          ),
        ),
      ],
    );
  }
}
