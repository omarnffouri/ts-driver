import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/utils/widget_utils.dart';
import '../../controllers/profile_add_accident_history_controller.dart';

class TraffictHeader extends StatelessWidget {
  const TraffictHeader({
    super.key,
    required this.controller,
  });

  final ProfileAddAccidentHistoryController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        addVerticalSpace(10.h),
        SizedBox(
          height: 40.h,
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: kMainColor,
                    alignment: Alignment.center,
                  ),
                  child: const AppText(
                    text: 'Add',
                    size: 15,
                    color: kWhiteColor,
                    weight: FontWeight.bold,
                  ),
                  onPressed: () {
                    controller.addTrafficsConvictionFields();
                  },
                ),
              )
            ],
          ),
        ),
        addVerticalSpace(20.h),
      ],
    );
  }
}
