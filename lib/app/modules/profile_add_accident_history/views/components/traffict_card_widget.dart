// ignore_for_file: invalid_use_of_protected_member

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:ts_driver/app/core/gen/fonts.gen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';

import '../../../../core/widgets/common_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/theme_extensions.dart';
import '../../../../core/utils/widget_utils.dart';
import '../../controllers/profile_add_accident_history_controller.dart';

class TraffictCard extends StatelessWidget {
  const TraffictCard({
    super.key,
    required this.controller,
    required this.index,
  });

  final ProfileAddAccidentHistoryController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 10.h,
      ),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.all(Radius.circular(20.r)),
        border: Border.all(color: context.dividerColor),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppText(
                  text:
                      '(${index + 1}/${controller.trafficConvictions.length})'),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  splashColor: kMainColor,
                  onTap: () {
                    controller.removeTrafficsConvictionFields(index);
                  },
                  child: const Icon(
                    Icons.delete_forever_outlined,
                    size: 25,
                    color: kMainColor,
                  ),
                ),
              )
            ],
          ),
          addVerticalSpace(6.h),
          GestureDetector(
            child: TextFormField(
              controller: controller.trafficConvictions[index].dateController,
              readOnly: true,
              style: TextStyle(fontSize: 15.sp),
              onChanged: (val) {},
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Date is Required';
                }
                return null;
              },
              onTap: () async {
                final DateTime? pickedDate = await showAppDatePicker(context);
                if (pickedDate != null) {
                  final formattedDate =
                      DateFormat('MM-dd-yyyy').format(pickedDate);
                  controller.trafficConvictions[index].dateController.text =
                      formattedDate;
                }
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(top: 30.h, left: 10.w),
                suffixIcon: Icon(
                  Icons.calendar_month,
                  size: 18.h,
                ),
                suffixIconColor: context.secondaryTextColor,
                labelStyle: TextStyle(
                  color: context.primaryTextColor,
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
                labelText: 'Select accident date',
                hintText: 'Select accident date',
              ),
            ),
          ),
          addVerticalSpace(20.h),
          CustomTextFieldWidget(
            keyboardType: TextInputType.text,
            hintText: "Description",
            labelText: "Description",
            validatorMsg: "Description is Required",
            onChange: (val) {},
            textController:
                controller.trafficConvictions[index].descriptionController,
          ),
          addVerticalSpace(20.h),
          CustomTextFieldWidget(
            keyboardType: TextInputType.text,
            hintText: "Fatalities",
            labelText: "Fatalities",
            validatorMsg: "Fatalities is Required",
            onChange: (val) {},
            textController:
                controller.trafficConvictions[index].fatalitiesController,
          ),
          addVerticalSpace(20.h),
          CustomTextFieldWidget(
            keyboardType: TextInputType.text,
            hintText: "Injuries",
            labelText: "Injuries",
            validatorMsg: "Injuries is Required",
            onChange: (val) {},
            textController:
                controller.trafficConvictions[index].injuriesController,
          ),
          addVerticalSpace(20.h),
          const Row(
            children: [
              AppText(
                text: 'Vehicle Type',
                size: 14,
              )
            ],
          ),
          addVerticalSpace(8.h),
          DropdownSearch<String>(
            decoratorProps: DropDownDecoratorProps(
              baseStyle: TextStyle(fontSize: 15.sp),
            ),
            items: (filter, infiniteScrollProps) => ["Personal", "Commercial"],
            onChanged: (val) {
              controller.trafficConvictions[index].vehicleType = val!;
            },
            selectedItem: "Personal",
            validator: (item) {
              if (item == null) {
                return "State Required";
              } else {
                return null;
              }
            },
          ),
          addVerticalSpace(10.h)
        ],
      ),
    );
  }
}
