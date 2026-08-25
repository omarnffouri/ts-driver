import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/widget_utils.dart';
import '../../../../../core/widgets/app_back_button.dart';
import '../../../../../core/widgets/app_red_header.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../controllers/documents_controller.dart';

class DocumentsAppBar extends GetView<DocumentsController> {
  const DocumentsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppRedHeader(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AppBackButton(),
          addHorizontalSpace(10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  text: 'Documents',
                  weight: FontWeight.bold,
                  maxLines: 2,
                  color: Colors.white,
                ),
                AppText(
                  text: controller
                          .user.personalDetails?.firstName?.capitalizeFirst ??
                      '',
                  size: 14,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ).paddingOnly(top: 10, left: 10, right: 10, bottom: 12),
    );
  }
}
