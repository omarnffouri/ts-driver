import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';

import 'common_widget.dart';
import 'app_botton.dart';

Future<bool?> showUpdateDialog({
  required BuildContext context,
  required Widget title,
  required TextEditingController controller,
  required Function() onTap,
  required String label,
  final inputFormatter,
  String? description,
  String? cancelActionText,
  String defaultActionText = 'OK',
}) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Center(child: title),
      insetPadding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 10.h,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20.0.r),
        ),
      ),
      content: description != null ? Text(description) : null,
      elevation: 2,
      actions: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 8.h,
            horizontal: 8.w,
          ),
          child: Column(
            children: [
              CustomTextFieldWidget(
                inputFormater: inputFormatter,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: false,
                ),
                hintText: "(313)111 1111",
                labelText: label,
                validatorMsg: "Other Phone Number Required",
                textController: controller,
                suffixIcon: Icon(
                  Icons.add_call,
                  size: 17.w,
                ),
                obsecure: false,
                isRequired: false,
              ),
              addVerticalSpace(50.h),
              AppButton(
                text: 'Submit',
                onPressed: onTap,
                bgColor: kMainColor,
              ),
              addVerticalSpace(20.h),
            ],
          ),
        ),
      ],
    ),
  );
}
