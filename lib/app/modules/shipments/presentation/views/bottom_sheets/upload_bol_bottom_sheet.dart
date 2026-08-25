import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/helpers/permission_helper.dart';
import 'package:ts_driver/app/core/utils/functions.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_botton.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/field_error_text.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

import '../../../domain/entities/shipment_entity.dart';
import '../../controllers/shipments_controller.dart';
import '../dialogs/trip_completed_dialog.dart';
import 'bol_category_card.dart';
import 'sheet_header.dart';

const int _maxFilesPerGroup = 5;

class UploadBolBottomSheet extends GetView<ShipmentsController> {
  const UploadBolBottomSheet({
    super.key,
    required this.shipment,
    this.isBolRejected = false,
  });
  final ShipmentEntity shipment;
  final bool isBolRejected;

  @override
  Widget build(BuildContext context) {
    final groups = <({
      IconData icon,
      String title,
      bool isRequired,
      String emptyHint,
      RxList<File> files,
      RxnString? error,
    })>[
      (
        icon: Icons.description_rounded,
        title: 'BOL Photos',
        isRequired: true,
        emptyHint: 'Photograph the signed BOL to complete the trip.',
        files: controller.bolNumberFiles,
        error: controller.bolFilesError,
      ),
      (
        icon: Icons.receipt_long_rounded,
        title: 'Lumper',
        isRequired: false,
        emptyHint: 'Add lumper receipts (optional).',
        files: controller.lumberFiles,
        error: null,
      ),
      (
        icon: Icons.local_gas_station_rounded,
        title: 'Fuel',
        isRequired: false,
        emptyHint: 'Add fuel receipts (optional).',
        files: controller.fuelFiles,
        error: null,
      ),
      (
        icon: Icons.more_horiz_rounded,
        title: 'Other',
        isRequired: false,
        emptyHint: 'Anything else worth documenting (optional).',
        files: controller.otherFiles,
        error: null,
      ),
    ];
    return Obx(() {
      final uploading = controller.isUploadingBolNumber.value;
      return Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.85,
          minHeight: Get.height * 0.3,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dim + lock the form while submitting.
            Flexible(
              child: IgnorePointer(
                ignoring: uploading,
                child: AnimatedOpacity(
                  opacity: uploading ? 0.45 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      SheetHeader(
                        icon: Icons.upload_file_rounded,
                        accent: AppColors.error,
                        title: isBolRejected ? 'Re-upload BOL' : 'Upload BOL',
                        subtitle: _subtitle(),
                        trailerId: shipment.trailerId,
                      ),
                      addVerticalSpace(14.h),
                      if (isBolRejected) ...[
                        const _RejectedBanner(),
                        addVerticalSpace(12.h),
                      ],
                      _CompletenessStrip(controller: controller),
                      addVerticalSpace(14.h),
                      _BolNumberField(controller: controller),
                      addVerticalSpace(18.h),
                      Flexible(
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: groups.length,
                          separatorBuilder: (_, __) => addVerticalSpace(12.h),
                          itemBuilder: (context, i) {
                            final g = groups[i];
                            return BolCategoryCard(
                              icon: g.icon,
                              label: g.title,
                              files: g.files,
                              maxFiles: _maxFilesPerGroup,
                              emptyHint: g.emptyHint,
                              isRequired: g.isRequired,
                              error: g.error,
                              onAdd: (scroll) async {
                                await _addFile(g.files);
                                if (g.error != null && g.files.isNotEmpty) {
                                  g.error!.value = null;
                                }
                                await Future.delayed(
                                    const Duration(milliseconds: 250));
                                if (scroll.hasClients) {
                                  scroll.animateTo(
                                    scroll.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                }
                              },
                              onRemove: (idx) => _removeFile(g.files, idx),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            addVerticalSpace(14.h),
            _SubmitBar(
              shipment: shipment,
              isBolRejected: isBolRejected,
              controller: controller,
            ),
          ],
        ),
      );
    });
  }

  String? _subtitle() {
    final number = shipment.shipmentNumber?.trim();
    if (number == null || number.isEmpty || number == 'null') return null;
    return 'Shipment #$number';
  }
}

class _RejectedBanner extends StatelessWidget {
  const _RejectedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.errorSurfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error.applyOpacity(.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.report_problem_rounded,
              size: 20.w, color: AppColors.error),
          addHorizontalSpace(10.w),
          Expanded(
            child: AppText(
              text:
                  'Your previous BOL was rejected. Re-take clear photos of the signed BOL.',
              size: 12,
              maxLines: 3,
              color: context.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletenessStrip extends StatelessWidget {
  const _CompletenessStrip({required this.controller});
  final ShipmentsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ready = controller.isBolReady;
      final color = ready ? context.successTextColor : AppColors.error;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: ready
              ? context.successTextColor.applyOpacity(.10)
              : context.errorSurfaceColor,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            Icon(
              ready ? Icons.check_circle_rounded : Icons.error_outline_rounded,
              size: 16.w,
              color: color,
            ),
            addHorizontalSpace(8.w),
            Expanded(
              child: AppText(
                text: ready ? 'Ready to submit' : 'BOL photos required',
                size: 12,
                weight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _BolNumberField extends StatelessWidget {
  const _BolNumberField({required this.controller});
  final ShipmentsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3.w,
              height: 14.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            addHorizontalSpace(8.w),
            AppText(
              text: 'BOL Number',
              size: 13.5,
              weight: FontWeight.w700,
              color: context.strongTextColor,
            ),
          ],
        ),
        addVerticalSpace(8.h),
        Obx(() {
          final error = controller.bolNumberError.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color:
                        error != null ? AppColors.error : context.dividerColor,
                    width: error != null ? 1.4 : 1,
                  ),
                  boxShadow: context.cardShadow,
                ),
                child: TextField(
                  controller: controller.bolNumberController,
                  style: TextStyle(
                      color: context.primaryTextColor, fontSize: 14.sp),
                  cursorColor: AppColors.primary,
                  onChanged: (_) {
                    if (controller.bolNumberError.value != null) {
                      controller.bolNumberError.value = null;
                    }
                  },
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Enter BOL number',
                    hintStyle:
                        TextStyle(color: context.hintColor, fontSize: 14.sp),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                    prefixIcon: Icon(Icons.tag_rounded,
                        size: 18.w, color: context.hintColor),
                  ),
                ),
              ),
              if (error != null) FieldErrorText(error),
            ],
          );
        }),
      ],
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({
    required this.shipment,
    required this.isBolRejected,
    required this.controller,
  });
  final ShipmentEntity shipment;
  final bool isBolRejected;
  final ShipmentsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final uploading = controller.isUploadingBolNumber.value;
      final ready = controller.isBolReady;
      final active = ready || uploading;
      return AppButton(
        text: uploading
            ? 'Submitting…'
            : (ready ? 'Submit' : 'Add BOL photos to submit'),
        bgColor: active ? AppColors.primary : context.inputFillColor,
        textColor: active ? AppColors.onPrimary : context.hintColor,
        width: double.infinity,
        hight: 50,
        radius: 12,
        fontWeight: FontWeight.bold,
        isLoading: uploading,
        icon: Icon(
          ready ? Icons.check_circle : Icons.lock_outline_rounded,
          color: active ? AppColors.onPrimary : context.hintColor,
          size: 18,
        ),
        onPressed: () async {
          final completed = await controller.completeShipment(
            shipmentId: shipment.id.toString(),
            isBolRejected: isBolRejected,
          );
          if (!completed) return;
          Navigator.of(Get.overlayContext!).pop(true);
          await showTripCompletedDialog(isBolRejected: isBolRejected);
        },
      );
    });
  }
}

Future<void> _addFile(RxList<File> files) async {
  if (!(await PermissionHelper.haveCameraPermission(
      "Grant camera permission in settings to click photos."))) {
    return;
  }
  final File? file = await getImage(imageSource: ImageSource.camera);
  if (file != null) {
    files.add(File(file.path));
    files.refresh();
  }
}

void _removeFile(RxList<File> files, int index) {
  files.removeAt(index);
}
