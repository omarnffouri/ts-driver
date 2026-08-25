import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/utils/widget_utils.dart';
import '../../controllers/profile_add_accident_history_controller.dart';

class AccidentHeader extends StatelessWidget {
  const AccidentHeader({
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(
                        text: 'Add',
                        size: 15,
                        color: kWhiteColor,
                        weight: FontWeight.bold,
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      )
                    ],
                  ),
                  onPressed: () {
                    controller.addAccidentReviewFields();
                  },
                ),
              ),
            ],
          ),
        ),
        addVerticalSpace(20.h),
      ],
    );
  }
}
