import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_botton.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/field_error_text.dart';

import '../../../domain/entities/shipment_entity.dart';
import '../../controllers/shipments_controller.dart';
import 'sheet_header.dart';

class RejectionBottomSheet extends GetView<ShipmentsController> {
  const RejectionBottomSheet({super.key, required this.shipment});

  final ShipmentEntity shipment;

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.error;
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(
              color: accent
                  .applyOpacity(context.statusTintAlpha(isTransit: false)),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cancel_rounded, size: 30.w, color: accent),
          ),
          addVerticalSpace(16.h),
          AppText(
            text: 'Reject this trip?',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: context.primaryTextColor,
            ),
          ),
          addVerticalSpace(8.h),
          AppText(
            text: "We'll ask for a quick reason, then notify dispatch.",
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.4,
              color: context.secondaryTextColor,
            ),
          ),
          addVerticalSpace(18.h),
          _ShipmentContextCard(shipment: shipment),
          addVerticalSpace(22.h),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50.h,
                  child: OutlinedButton(
                    onPressed: Get.back,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: context.tileColor,
                      side: BorderSide(color: context.dividerColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: AppText(
                      text: 'Keep',
                      color: context.primaryTextColor,
                      weight: FontWeight.w600,
                      size: 15,
                    ),
                  ),
                ),
              ),
              addHorizontalSpace(12.w),
              Expanded(
                child: AppButton(
                  text: 'Reject',
                  bgColor: accent,
                  width: double.infinity,
                  hight: 50,
                  radius: 12,
                  fontWeight: FontWeight.bold,
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.onPrimary, size: 18),
                  onPressed: () {
                    Get.back();
                    rejectReasonDialog(shipment: shipment);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void rejectReasonDialog({required ShipmentEntity shipment}) {
    showAppBottomSheet(
      isScrollControlled: true,
      child: _RejectReasonSheet(shipment: shipment),
    );
  }
}

class _ShipmentContextCard extends StatelessWidget {
  const _ShipmentContextCard({required this.shipment});

  final ShipmentEntity shipment;

  @override
  Widget build(BuildContext context) {
    final route = shipment.routeSummary;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.tileColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: context.dividerColor),
            ),
            child: Icon(Icons.inventory_2_rounded,
                size: 19.w, color: context.secondaryTextColor),
          ),
          addHorizontalSpace(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: shipment.shipmentNumber ?? 'Shipment',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: context.primaryTextColor,
                  ),
                ),
                if (route.isNotEmpty) ...[
                  addVerticalSpace(2.h),
                  AppText(
                    text: route,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: context.secondaryTextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RejectReasonSheet extends StatefulWidget {
  const _RejectReasonSheet({required this.shipment});

  final ShipmentEntity shipment;

  @override
  State<_RejectReasonSheet> createState() => _RejectReasonSheetState();
}

class _RejectReasonSheetState extends State<_RejectReasonSheet> {
  static const _quickReasons = [
    'Distance too far',
    'Rate too low',
    'Schedule conflict',
    'Equipment issue',
    'Unsafe load',
  ];

  final _controller = TextEditingController();
  String? _selected;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyQuick(String reason) {
    HapticFeedback.selectionClick();
    setState(() {
      _selected = reason;
      _controller.text = reason;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: reason.length),
      );
      _error = null;
    });
  }

  void _submit() {
    final reason = _controller.text.trim();
    if (reason.isEmpty) {
      setState(() => _error = 'Please add a short reason.');
      return;
    }
    Navigator.pop(Get.overlayContext!);
    Get.find<ShipmentsController>().updateShipment(
      shipment: widget.shipment,
      status: 'rejected',
      reason: reason,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetHeader(
              icon: Icons.edit_note_rounded,
              accent: AppColors.error,
              title: 'Reason for rejection',
              trailerId: widget.shipment.shipmentNumber,
            ),
            addVerticalSpace(8.h),
            AppText(
              text: "Let dispatch know why you're passing on this load.",
              maxLines: 2,
              style: TextStyle(
                fontSize: 12.5.sp,
                height: 1.4,
                color: context.secondaryTextColor,
              ),
            ),
            addVerticalSpace(16.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final r in _quickReasons)
                  _QuickReasonChip(
                    label: r,
                    selected: _selected == r,
                    onTap: () => _applyQuick(r),
                  ),
              ],
            ),
            addVerticalSpace(16.h),
            Container(
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color:
                      _error != null ? AppColors.error : context.dividerColor,
                  width: _error != null ? 1.4 : 1,
                ),
                boxShadow: context.cardShadow,
              ),
              child: TextField(
                controller: _controller,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                cursorColor: AppColors.primary,
                style:
                    TextStyle(color: context.primaryTextColor, fontSize: 14.sp),
                onChanged: (v) {
                  final clearSelection = _selected != null && _selected != v;
                  if (clearSelection || _error != null) {
                    setState(() {
                      if (clearSelection) _selected = null;
                      _error = null;
                    });
                  }
                },
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                  hintText: 'I’m rejecting this trip because…',
                  hintStyle:
                      TextStyle(color: context.hintColor, fontSize: 14.sp),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                ),
              ),
            ),
            if (_error != null) FieldErrorText(_error!),
            addVerticalSpace(18.h),
            AppButton(
              text: 'Submit',
              bgColor: AppColors.primary,
              width: double.infinity,
              hight: 50,
              radius: 12,
              fontWeight: FontWeight.bold,
              icon: const Icon(Icons.send_rounded,
                  color: AppColors.onPrimary, size: 18),
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickReasonChip extends StatelessWidget {
  const _QuickReasonChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.error;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected
              ? accent.applyOpacity(context.statusTintAlpha(isTransit: false))
              : context.tileColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? accent : context.dividerColor,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: AppText(
          text: label,
          size: 12.5,
          weight: FontWeight.w600,
          color: selected ? accent : context.secondaryTextColor,
        ),
      ),
    );
  }
}
