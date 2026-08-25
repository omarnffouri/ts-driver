// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:ts_driver/app/core/gen/fonts.gen.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';

import '../../../../../core/widgets/app_checkbox.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/theme_extensions.dart';
import '../../../domain/entities/form_entity.dart';
import '../../controllers/forms_controller.dart';

class FormFieldRow extends StatelessWidget {
  final int formId;
  final String fieldType;
  final FormFieldEntity formField;
  final Function onSubmit;
  FormFieldRow(
      {super.key,
      required this.formId,
      this.fieldType = 'text',
      required this.formField,
      required this.onSubmit});

  final controller = Get.find<FormsController>();

  @override
  Widget build(BuildContext context) {
    final isVaiolatedForm = formId == 75;
    if (formField.formFieldsValue == null) {
      return const SizedBox();
    }
    switch (fieldType) {
      case 'editor':
        return Column(
          children: [
            Html(data: formField.formFieldsValue!.value, style: {
              "h2":
                  Style(fontSize: FontSize(18.sp), fontWeight: FontWeight.bold),
              "h3": Style(fontSize: FontSize(15.sp)),
              "h4": Style(fontSize: FontSize(15.sp)),
              "p": Style(fontSize: FontSize(15.sp)),
            }),
            addVerticalSpace(8.h),
          ],
        );
      case 'string':
        return AppTextAreaWidget(
          txtLabel: formField.label!,
          txtValue: formField.formFieldsValue!.value,
          isRequired: isVaiolatedForm ? false : formField.isRequired! == 1,
          isVaiolatedForm: isVaiolatedForm,
          txtController: formField.textEditingController,
          focusNode: formField.focusNode,
          onSubmit: onSubmit,
        );
      case 'textarea':
        return AppTextAreaWidget(
          txtLabel: formField.label!,
          txtValue: formField.formFieldsValue!.value,
          isRequired: isVaiolatedForm ? false : formField.isRequired! == 1,
          isVaiolatedForm: isVaiolatedForm,
          minLines: 4,
          maxLines: null,
          focusNode: formField.focusNode,
          txtController: formField.textEditingController,
          onSubmit: onSubmit,
        );
      case 'checkbox':
        return Column(
          children: [
            if (isVaiolatedForm && formField.formFieldsValue!.value.isNotEmpty)
              CustomCheckbox(
                value: isVaiolatedForm
                    ? formField.formFieldsValue!.value.isNotEmpty
                    : true,
                text: formField.label!,
                onChange: null,
                focusNode: formField.focusNode,
              ),
            addVerticalSpace(5.h),
          ],
        );
      case 'date':
        return AppDateWidget(
          txtLabel: formField.label!,
          txtValue: formField.formFieldsValue!.value,
          isRequired: formField.isRequired! == 1,
          txtController: formField.textEditingController,
          focusNode: formField.focusNode,
        );
      case 'signature':
        return AppSignatureWidget(
          txtLabel: formField.label!,
          txtValue: formField.formFieldsValue!.value,
        );
      default:
    }
    return const SizedBox();
  }
}

class AppTextAreaWidget extends StatelessWidget {
  AppTextAreaWidget({
    super.key,
    required this.txtLabel,
    required this.txtValue,
    required this.isRequired,
    required this.isVaiolatedForm,
    this.minLines = 1,
    this.maxLines,
    this.txtController,
    required this.focusNode,
    required this.onSubmit,
  });

  final String txtLabel;
  final String txtValue;
  final int minLines;
  final int? maxLines;
  final bool isRequired;
  final bool isVaiolatedForm;
  TextEditingController? txtController;
  final FocusNode focusNode;
  final Function onSubmit;

  @override
  Widget build(BuildContext context) {
    bool canEdit = isVaiolatedForm ? false : txtValue.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: txtLabel,
            style: TextStyle(
              color: context.primaryTextColor,
              fontSize: 13.sp,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 15.sp,
                  ),
                ),
            ],
          ),
        ),
        addVerticalSpace(8.h),
        TextFormField(
          minLines: minLines,
          maxLines: maxLines,
          enabled: canEdit,
          focusNode: focusNode,
          controller: txtController,
          validator: isRequired && txtValue.isEmpty
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This Field is Required*';
                  }
                  return null;
                }
              : null,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (value) {
            onSubmit();
          },
          onTapOutside: (value) {
            focusNode.unfocus();
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: context.dividerColor),
              gapPadding: 4,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: AppColors.primary),
              gapPadding: 4,
            ),
            errorStyle: const TextStyle(color: AppColors.error),
            filled: true,
            fillColor: context.cardColor,
            hintText: txtValue,
            isDense: true,
            contentPadding: EdgeInsets.all(10.w),
          ),
        ),
        addVerticalSpace(8),
      ],
    );
  }
}

class AppDateWidget extends StatelessWidget {
  AppDateWidget({
    super.key,
    required this.txtLabel,
    required this.txtValue,
    required this.isRequired,
    required this.txtController,
    required this.focusNode,
  });
  final String txtLabel;
  final String txtValue;
  final bool isRequired;
  TextEditingController txtController;
  FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    bool showPicker = isRequired && txtValue.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: '$txtLabel:',
          weight: FontWeight.w500,
          size: 14.sp,
        ),
        addVerticalSpace(8.h),
        if (showPicker)
          GestureDetector(
            child: TextFormField(
              controller: txtController,
              focusNode: focusNode,
              readOnly: true,
              style: TextStyle(
                overflow: TextOverflow.ellipsis,
                fontSize: 14.sp,
                color: context.primaryTextColor,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a Date';
                }
                return null; // return null if the input is valid
              },
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2050),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: AppColors.primary,
                              onPrimary: AppColors.onPrimary,
                            ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  final formattedDate =
                      DateFormat('MM-dd-yyyy').format(pickedDate);
                  txtController.text = formattedDate;
                }
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(top: 30.h, left: 10.w),
                suffixIcon: Icon(
                  Icons.calendar_month,
                  size: 20.w,
                ),
                suffixIconColor: context.secondaryTextColor,
                labelStyle: TextStyle(
                  color: context.hintColor,
                  fontSize: 14.sp,
                  fontFamily: FontFamily.poppins,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: context.dividerColor),
                  borderRadius: BorderRadius.all(Radius.circular(10.r)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(width: 1, color: AppColors.primary),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                hintStyle: TextStyle(fontSize: 16.sp),
                labelText: txtLabel,
                hintText: 'Select the Date',
              ),
            ),
          ),
        if (showPicker == false)
          AppText(
            text: txtValue,
            size: 14.sp,
          ),
        addVerticalSpace(8.w),
      ],
    );
  }
}

class AppSignatureWidget extends StatelessWidget {
  const AppSignatureWidget({
    super.key,
    required this.txtLabel,
    required this.txtValue,
  });

  final String txtLabel;
  final String txtValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(text: "$txtLabel ", size: 13.sp),
        addVerticalSpace(8.h),
        Container(
          height: 110.h,
          width: double.infinity,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(color: context.dividerColor),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: ColoredBox(
            color: AppColors.lightSignaturePanel,
            child: CachedNetworkImage(
              imageUrl: txtValue,
              fit: BoxFit.fill,
              placeholder: (_, __) => Shimmer.fromColors(
                baseColor: context.shimmerBaseColor,
                highlightColor: context.shimmerHighlightColor,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: context.shimmerBaseColor,
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
        addVerticalSpace(8.h),
      ],
    );
  }
}
