import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/widget_utils.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/file_viewer.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/theme_extensions.dart';
import '../../../forms/domain/entities/signed_form_entity.dart';
import '../../controllers/signed_forms_controller.dart';

Future<void> showSignedFormActions(SignedFormEntity form) {
  return showAppBottomSheet<void>(child: _SignedFormActionsSheet(form: form));
}

class _SignedFormActionsSheet extends StatelessWidget {
  const _SignedFormActionsSheet({required this.form});

  final SignedFormEntity form;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignedFormsController>();
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: form.formName ?? 'Signed form',
            maxLines: 2,
            size: 15,
            weight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
          SizedBox(height: 8.h),
          _ActionTile(
            icon: Icons.visibility_rounded,
            label: 'View',
            onTap: () {
              Get.back();
              Get.to(
                () => FileViewer(
                  title: form.formName ?? '',
                  path: form.signedFormUrl ?? '',
                  folderName: 'forms_docs',
                  fileLoaded: () {},
                ),
              );
            },
          ),
          _ActionTile(
            icon: Icons.download_rounded,
            label: 'Download',
            onTap: () {
              Get.back();
              controller.downloadForm(form);
            },
          ),
          _ActionTile(
            icon: Icons.share_rounded,
            label: 'Share',
            onTap: () {
              Get.back();
              controller.shareForm(form);
            },
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          child: Row(
            children: [
              Icon(icon, size: 22.w, color: AppColors.primary),
              SizedBox(width: 14.w),
              AppText(
                text: label,
                size: 14,
                color: context.primaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
