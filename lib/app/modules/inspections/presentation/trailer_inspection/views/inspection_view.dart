import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ts_driver/app/core/utils/app_svgs.dart';
import 'package:ts_driver/app/core/widgets/app_back_button.dart';
import 'package:ts_driver/app/core/widgets/app_botton.dart';
import 'package:ts_driver/app/core/widgets/app_red_header.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/glass_segmented_tabs.dart';
import '../../components/damage_side_card.dart';
import '../../components/inspection_notes_field.dart';
import '../../widgets/inspection_row.dart';
import '../../components/inspection_section.dart';
import '../../components/tire_grid.dart';
import '../../widgets/tire_summary.dart';
import '../../../domain/entities/inspection_damage.dart';
import '../../../domain/entities/inspection_enums.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

import '../controllers/inspection_controller.dart';

class InspectionView extends StatefulWidget {
  const InspectionView({super.key});

  @override
  State<InspectionView> createState() => _InspectionViewState();
}

class _InspectionViewState extends State<InspectionView> {
  final InspectionController controller = Get.find<InspectionController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Get.back(result: false);
        return false;
      },
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: Column(
          children: [
            const _InspectionHeader(),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    18.h,
                    16.w,
                    16.h + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _IdentitySection(),
                      SizedBox(height: 22.h),
                      Obx(
                        () => controller.activeTab == InspectionTabs.reefer
                            ? Padding(
                                padding: EdgeInsets.only(bottom: 22.h),
                                child: const _ReeferSection(),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const _DamagesSection(),
                      SizedBox(height: 22.h),
                      const _TiresSection(),
                      SizedBox(height: 22.h),
                      InspectionNotesField(
                        controller: controller.notesController,
                        scrollController: _scrollController,
                        hint: 'Add any notes about the trailer condition…',
                      ),
                      SizedBox(height: 24.h),
                      const _SubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InspectionHeader extends GetView<InspectionController> {
  const _InspectionHeader();

  @override
  Widget build(BuildContext context) {
    return AppRedHeader(
      radius: 28,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 6.h, 16.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppBackButton(onTap: () => Get.back(result: false)),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText(
                          text: 'Trailer Inspection',
                          size: 19,
                          weight: FontWeight.w700,
                          color: Colors.white,
                          maxLines: 1,
                        ),
                        SizedBox(height: 2.h),
                        AppText(
                          text: 'Pre-trip safety & condition check',
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Obx(
                  () => GlassSegmentedTabs<InspectionTabs>(
                    value: controller.activeTab,
                    segments: const {
                      InspectionTabs.van: 'VAN',
                      InspectionTabs.reefer: 'REEFER',
                    },
                    onChanged: controller.changeTab,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IdentitySection extends GetView<InspectionController> {
  const _IdentitySection();

  @override
  Widget build(BuildContext context) {
    return InspectionSection(
      title: 'Trailer',
      icon: Icons.local_shipping_outlined,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
      child: Column(
        children: [
          InspectionRow(
            icon: Icons.local_shipping_outlined,
            label: 'Trailer #',
            trailing: _value(context, controller.trailerNo),
          ),
          Divider(height: 1, color: context.dividerColor),
          InspectionRow(
            icon: Icons.confirmation_number_outlined,
            label: 'Trip #',
            trailing: _value(context, controller.tripNo),
          ),
        ],
      ),
    );
  }

  Widget _value(BuildContext context, String value) => AppText(
        text: value,
        size: 15,
        weight: FontWeight.w700,
        color: context.strongTextColor,
      );
}

class _ReeferSection extends GetView<InspectionController> {
  const _ReeferSection();

  @override
  Widget build(BuildContext context) {
    return InspectionSection(
      title: 'Reefer',
      icon: Icons.ac_unit_rounded,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
      child: Column(
        children: [
          InspectionRow(
            icon: Icons.water_drop_rounded,
            label: 'Oil',
            onTap: controller.showOilBottomSheet,
            trailing: Obx(() {
              final low = controller.oilStatus == OilStatus.low;
              return ValuePill(value: low ? 'Low' : 'Full', warn: low);
            }),
          ),
          Divider(height: 1, color: context.dividerColor),
          InspectionRow(
            icon: Icons.local_gas_station_rounded,
            label: 'Fuel',
            onTap: controller.showFuelBottomSheet,
            trailing: Obx(() => ValuePill(
                  value: controller.fuelStatus,
                  warn: controller.fuelStatus == FuelStatus.empty,
                )),
          ),
        ],
      ),
    );
  }
}

class _DamagesSection extends GetView<InspectionController> {
  const _DamagesSection();

  @override
  Widget build(BuildContext context) {
    final sides = <(ContainerSides, String, String, RxList<InspectionDamage>)>[
      (
        ContainerSides.one,
        'Left',
        AppSvgs.containerSide_1,
        controller.containerDamagesSide1
      ),
      (
        ContainerSides.two,
        'Front',
        AppSvgs.containerSide_2,
        controller.containerDamagesSide2
      ),
      (
        ContainerSides.three,
        'Right',
        AppSvgs.containerSide_3,
        controller.containerDamagesSide3
      ),
      (
        ContainerSides.four,
        'Back',
        AppSvgs.containerSide_4,
        controller.containerDamagesSide4
      ),
      (
        ContainerSides.five,
        'Inside',
        AppSvgs.containerSide_5,
        controller.containerDamagesSide5
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InspectionSectionHeader(
          title: 'Damages',
          icon: Icons.report_problem_outlined,
          trailing: Obx(() {
            final total = sides.fold<int>(0, (sum, s) => sum + s.$4.length);
            return total == 0
                ? const SizedBox.shrink()
                : InspectionCountBadge(count: total);
          }),
        ),
        for (var i = 0; i < sides.length; i++) ...[
          if (i > 0) SizedBox(height: 14.h),
          DamageSideCard(
            label: sides[i].$2,
            svgPath: sides[i].$3,
            damages: sides[i].$4,
            onSelect: (scroll) => controller.showDamagesBottomSheet(
                sides[i].$1, sides[i].$4, scroll),
            onAdd: (scroll) => controller.addContainerImagePressed(
                sides[i].$1, scroll, sides[i].$4),
            onRemove: (index) =>
                controller.removeDamage(sides[i].$4, index, sides[i].$1),
          ),
        ],
      ],
    );
  }
}

class _TiresSection extends GetView<InspectionController> {
  const _TiresSection();

  @override
  Widget build(BuildContext context) {
    return InspectionSection(
      title: 'Tire Inspection',
      icon: Icons.tire_repair_outlined,
      trailing: TireSummary(tires: controller.tires),
      child: TireGrid(
        layout: controller.tireLayout,
        tires: controller.tires,
        onTap: controller.showTireBottomSheet,
      ),
    );
  }
}

class _SubmitButton extends GetView<InspectionController> {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppButton(
        text: 'Submit Inspection',
        bgColor: AppColors.primary,
        width: double.infinity,
        hight: 52.h,
        radius: 14,
        fontWeight: FontWeight.bold,
        isLoading: controller.isCreatingInspection,
        onPressed: controller.onSubmitClicked,
      ),
    );
  }
}
