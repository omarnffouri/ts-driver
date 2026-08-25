import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_back_button.dart';
import 'package:ts_driver/app/core/widgets/app_red_header.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/profile_image.dart';

class NotificationsHeader extends StatelessWidget {
  const NotificationsHeader({
    super.key,
    required this.profileUrl,
    required this.onBack,
  });

  final String? profileUrl;
  final Future<void> Function() onBack;

  @override
  Widget build(BuildContext context) {
    return AppRedHeader(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBackButton(onTap: onBack),
          addHorizontalSpace(10.w),
          const Expanded(
            child: AppText(
              text: "Notifications",
              weight: FontWeight.bold,
              maxLines: 2,
              color: Colors.white,
            ),
          ),
          ProfileImage.network(
            url: profileUrl,
            width: 30,
            height: 30,
          ),
        ],
      ),
    );
  }
}
