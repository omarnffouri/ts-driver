import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_botton.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/theme_extensions.dart';
import '../../controllers/documents_controller.dart';

class DocumentsUploadBar extends StatelessWidget {
  const DocumentsUploadBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentsController>();
    return Obx(() {
      final ready = controller.readyCount;
      final hasReady = ready > 0;
      return Container(
        decoration: BoxDecoration(
          color: context.panelColor,
          boxShadow: context.bottomBarShadow,
          border: Border(top: BorderSide(color: context.dividerColor)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
            child: AppButton(
              width: double.infinity,
              radius: 16,
              fontWeight: FontWeight.w600,
              isLoading: controller.isUploading,
              bgColor: hasReady ? AppColors.primary : context.dividerColor,
              textColor: hasReady ? Colors.white : context.hintColor,
              icon: hasReady
                  ? Icon(Icons.upload_rounded, size: 20.w, color: Colors.white)
                  : null,
              text: hasReady
                  ? (ready == 1
                      ? 'Upload 1 document'
                      : 'Upload $ready documents')
                  : 'Attach files to upload',
              onPressed: hasReady ? controller.uploadDocuments : () {},
            ),
          ),
        ),
      );
    });
  }
}
