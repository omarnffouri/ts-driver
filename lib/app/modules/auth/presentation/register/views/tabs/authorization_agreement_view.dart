import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/modules/forms/presintation/views/components/signature_section_widget.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

import '../../controllers/register_controller.dart';
import '../widgets/register_nav_bar.dart';
import '../widgets/register_section.dart';

class AuthorizationAgreementView extends GetView<RegisterController> {
  const AuthorizationAgreementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.backgroundColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RegisterSection(
                title: 'Authorization Agreement',
                icon: Icons.description_rounded,
                children: [
                  Obx(() {
                    final description = controller
                        .configrations.value.termsAndConditions?.description;
                    if (description == null) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }
                    return Html(
                      data: description,
                      style: {
                        'body': Style(
                          fontSize: FontSize(15.sp),
                          color: context.secondaryTextColor,
                        ),
                      },
                    );
                  }),
                ],
              ),
              SizedBox(height: 24.h),
              SafeArea(
                top: false,
                minimum: EdgeInsets.only(bottom: 8.h),
                child: RegisterNavBar(
                  onBack: controller.previousPage,
                  onNext: () => _openAgreementSheet(context),
                  nextText: 'Accept',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAgreementSheet(BuildContext context) {
    showAppBottomSheet(
      child: _AgreementSheet(controller: controller),
    );
  }
}

class _AgreementSheet extends StatefulWidget {
  const _AgreementSheet({required this.controller});

  final RegisterController controller;

  @override
  State<_AgreementSheet> createState() => _AgreementSheetState();
}

class _AgreementSheetState extends State<_AgreementSheet> {
  final Set<int> _expanded = {};

  RegisterController get controller => widget.controller;

  void _toggle(int i) {
    final a = controller.agreementList[i];
    a.isChecked = !(a.isChecked ?? false);
    controller.checkAllTermsAgreed();
    controller.agreementList.refresh();
  }

  void _toggleAll() {
    final next = !controller.isAllTermsAgreed.value;
    for (final a in controller.agreementList) {
      a.isChecked = next;
    }
    controller.checkAllTermsAgreed();
    controller.agreementList.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 0.85.sh,
      child: Column(
        children: [
          _header(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Obx(() => _checklist(context)),
                  SizedBox(height: 20.h),
                  SignatureSectionWidget(
                    controller: controller.signatureController,
                  ),
                ],
              ),
            ),
          ),
          _actionBar(context),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Obx(() {
      final total = controller.agreementList.length;
      final checked =
          controller.agreementList.where((a) => a.isChecked == true).length;
      final done = total > 0 && checked == total;
      final frac = total == 0 ? 0.0 : checked / total;
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppText(
                    text: 'Authorization & Agreement',
                    size: 17,
                    weight: FontWeight.w700,
                    color: context.strongTextColor,
                  ),
                ),
                _countChip(context, checked, total, done),
              ],
            ),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: SizedBox(
                height: 4.h,
                child: Stack(
                  children: [
                    Container(color: context.dividerColor),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: frac),
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      builder: (_, v, __) => FractionallySizedBox(
                        widthFactor: v.clamp(0.0, 1.0),
                        child: Container(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _countChip(BuildContext context, int checked, int total, bool done) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: context.primaryTint,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (done) ...[
            Icon(Icons.check_circle_rounded,
                size: 14.w, color: AppColors.primary),
            SizedBox(width: 4.w),
          ],
          AppText(
            text: '$checked of $total',
            size: 12,
            weight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _checklist(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < controller.agreementList.length; i++) {
      if (i > 0) rows.add(Divider(height: 1, color: context.dividerColor));
      rows.add(_item(context, i));
    }
    rows.add(Divider(height: 1, color: context.dividerColor));
    rows.add(_agreeAll(context));
    return RegisterSection(
      title: 'Required Agreements',
      icon: Icons.fact_check_rounded,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows),
      ],
    );
  }

  Widget _item(BuildContext context, int i) {
    final a = controller.agreementList[i];
    final checked = a.isChecked == true;
    final title = a.title ?? '';
    final isLong = title.length > 120;
    final expanded = _expanded.contains(i);
    return InkWell(
      onTap: () => _toggle(i),
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _glyph(context, checked),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: title,
                    size: 13.5,
                    weight: FontWeight.w500,
                    maxLines: isLong && !expanded ? 2 : 20,
                    color: checked
                        ? context.primaryTextColor
                        : context.secondaryTextColor,
                  ),
                  if (isLong) ...[
                    SizedBox(height: 4.h),
                    GestureDetector(
                      onTap: () => setState(() {
                        if (expanded) {
                          _expanded.remove(i);
                        } else {
                          _expanded.add(i);
                        }
                      }),
                      child: AppText(
                        text: expanded ? 'Show less' : 'Read more',
                        size: 12,
                        weight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _agreeAll(BuildContext context) {
    final all = controller.isAllTermsAgreed.value;
    return InkWell(
      onTap: _toggleAll,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            _glyph(context, all),
            SizedBox(width: 12.w),
            Expanded(
              child: AppText(
                text: 'I agree to all of the above',
                size: 13.5,
                weight: FontWeight.w600,
                color: context.strongTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glyph(BuildContext context, bool checked) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 22.w,
      height: 22.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: checked ? AppColors.primary : context.inputFillColor,
        borderRadius: BorderRadius.circular(6.r),
        border: checked
            ? null
            : Border.all(color: context.dividerColor, width: 1.5),
      ),
      child: checked
          ? Icon(Icons.check_rounded, size: 15.w, color: AppColors.onPrimary)
          : null,
    );
  }

  Widget _actionBar(BuildContext context) {
    return Obx(() {
      final ready = controller.isAllTermsAgreed.value;
      return Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
        decoration: BoxDecoration(
          color: context.sheetColor,
          border: Border(top: BorderSide(color: context.dividerColor)),
          boxShadow: context.bottomBarShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!ready) ...[
              AppText(
                text: 'Check all agreements to continue',
                size: 11.5,
                color: context.hintColor,
              ),
              SizedBox(height: 8.h),
            ],
            RegisterNavBar(
              onBack: Get.back,
              onNext: controller.register,
              nextText: 'Submit',
              enabled: ready,
            ),
          ],
        ),
      );
    });
  }
}
