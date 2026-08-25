import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../domain/entities/inspection_damage.dart';
import '../../../domain/entities/inspection_enums.dart';
import 'package:ts_driver/app/core/utils/app_svgs.dart';
import 'package:ts_driver/app/core/widgets/app_back_button.dart';
import 'package:ts_driver/app/core/widgets/app_botton.dart';
import 'package:ts_driver/app/core/widgets/app_red_header.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import '../../components/damage_side_card.dart';
import '../../components/inspection_notes_field.dart';
import '../../widgets/inspection_row.dart';
import '../../components/inspection_section.dart';
import '../../components/tire_grid.dart';
import '../../widgets/tire_summary.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

import '../controller/truck_inspection_controller.dart';

class TruckInspectionView extends StatefulWidget {
  const TruckInspectionView({super.key});

  @override
  State<TruckInspectionView> createState() => _TruckInspectionViewState();
}

class _TruckInspectionViewState extends State<TruckInspectionView> {
  final TruckInspectionController controller =
      Get.find<TruckInspectionController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Column(
        children: [
          const _TruckHeader(),
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
                    const _FluidsSection(),
                    SizedBox(height: 22.h),
                    const _DamagesSection(),
                    SizedBox(height: 22.h),
                    const _TiresSection(),
                    SizedBox(height: 22.h),
                    InspectionNotesField(
                      controller: controller.notesController,
                      scrollController: _scrollController,
                      hint: 'Add any notes about the truck condition…',
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
    );
  }
}

class _TruckHeader extends StatelessWidget {
  const _TruckHeader();

  @override
  Widget build(BuildContext context) {
    return AppRedHeader(
      radius: 28,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 6.h, 8.w, 18.h),
          child: Row(
            children: [
              AppBackButton(onTap: () => Get.back(result: false)),
              SizedBox(width: 6.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText(
                      text: 'Truck Inspection',
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
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Get.back(result: false),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  child: const AppText(
                    text: 'Skip',
                    size: 14,
                    weight: FontWeight.w700,
                    color: Colors.white,
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

class _FluidsSection extends GetView<TruckInspectionController> {
  const _FluidsSection();

  @override
  Widget build(BuildContext context) {
    return InspectionSection(
      title: 'Fluids',
      icon: Icons.opacity_rounded,
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

class _DamagesSection extends GetView<TruckInspectionController> {
  const _DamagesSection();

  @override
  Widget build(BuildContext context) {
    final sides = <(String, String, String, RxList<InspectionDamage>)>[
      (
        TruckSides.left,
        'Left',
        AppSvgs.truckLeftSide,
        controller.truckLeftSideDamages
      ),
      (
        TruckSides.front,
        'Front',
        AppSvgs.truckFrontSide,
        controller.truckFrontSideDamages
      ),
      (
        TruckSides.right,
        'Right',
        AppSvgs.truckRightSide,
        controller.truckRightSideDamages
      ),
      (
        TruckSides.back,
        'Back',
        AppSvgs.truckBackSide,
        controller.truckBackSideDamages
      ),
      (
        TruckSides.inside,
        'Inside',
        AppSvgs.truckInSide,
        controller.truckInsideDamages
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

class _TiresSection extends GetView<TruckInspectionController> {
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

class _SubmitButton extends GetView<TruckInspectionController> {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppButton(
        text: controller.haveInspectionData ? 'Submit Inspection' : 'Skip',
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
