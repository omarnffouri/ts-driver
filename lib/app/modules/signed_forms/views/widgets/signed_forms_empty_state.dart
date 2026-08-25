import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../theme/theme_extensions.dart';

class SignedFormsEmptyState extends StatelessWidget {
  const SignedFormsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(Assets.svg.signedForms, width: 120.w),
          SizedBox(height: 16.h),
          AppText(
            text: 'No signed forms yet',
            size: 16,
            weight: FontWeight.bold,
            color: context.primaryTextColor,
          ),
          SizedBox(height: 6.h),
          AppText(
            text: 'Forms you sign will appear here.',
            size: 13,
            color: context.secondaryTextColor,
          ),
        ],
      ),
    );
  }
}
