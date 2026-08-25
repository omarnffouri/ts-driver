import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:keyboard_detection/keyboard_detection.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/core/widgets/app_botton.dart';
import 'package:ts_driver/app/core/widgets/app_screen.dart';
import 'package:ts_driver/app/modules/forms/domain/entities/form_entity.dart';
import 'package:ts_driver/app/modules/forms/presintation/views/components/form_body.dart';
import 'package:ts_driver/app/modules/forms/presintation/views/components/form_attachment_item_view.dart';
import 'package:ts_driver/app/modules/forms/presintation/views/components/signature_section_widget.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/theme_extensions.dart';
import '../controllers/forms_controller.dart';
import 'components/form_appbar.dart';
import 'components/forms_empty_state_widget.dart';
import 'components/loading_indicator_widget.dart';

class FormsView extends GetView<FormsController> {
  const FormsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    log('FormsView');
    return KeyboardDetection(
      controller: KeyboardDetectionController(
        onChanged: (value) {
          if (value == KeyboardState.visible ||
              value == KeyboardState.visibling) {
            controller.isKeyboardHidden.value = false;
          } else if (value == KeyboardState.hidden ||
              value == KeyboardState.hiding) {
            controller.isKeyboardHidden.value = true;
          }
        },
      ),
      child: AppScreen(
        child: Scaffold(
          backgroundColor: context.backgroundColor,
          body: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Container(
              color: context.backgroundColor,
              child: Column(
                children: [
                  //
                  //
                  // header
                  const FormAppbar(),

                  //
                  //
                  // body
                  Expanded(
                    child: SmartRefresher(
                      controller: controller.refreshController,
                      header: const WaterDropMaterialHeader(),
                      onRefresh: controller.handleRefresh,
                      child: Obx(
                        () =>
                            //
                            // loading check
                            controller.isLoading
                                ? const LoadingIndicatorWidget()

                                //
                                // empty check
                                : controller.forms.isEmpty
                                    ? const FormsEmptyStateWidget()

                                    //
                                    // forms completion check
                                    : controller.isFormsCompleted.value
                                        ? const AllSetWidget(
                                            title: "Thank You!",
                                            subTitle: "All Done for the Moment",
                                          )

                                        //
                                        //
                                        // actual form builder / container
                                        : SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                //
                                                //
                                                // form main body widget
                                                FormBody(
                                                  formModel: controller.forms
                                                      .elementAt(
                                                    controller.activeStep.value,
                                                  ),
                                                ),

                                                //
                                                //
                                                // form videos view
                                                _FormAttachmentsView(
                                                  form: controller.forms
                                                      .elementAt(
                                                    controller.activeStep.value,
                                                  ),
                                                  attachmentType:
                                                      FormAttachmentType.video,
                                                ),

                                                //
                                                //
                                                // form attachments
                                                _FormAttachmentsView(
                                                  form: controller.forms
                                                      .elementAt(
                                                    controller.activeStep.value,
                                                  ),
                                                  attachmentType:
                                                      FormAttachmentType
                                                          .attachment,
                                                ),

                                                //
                                                //
                                                // other documents
                                                _FormAttachmentsView(
                                                  form: controller.forms
                                                      .elementAt(
                                                    controller.activeStep.value,
                                                  ),
                                                  attachmentType:
                                                      FormAttachmentType
                                                          .otherDocuments,
                                                ),

                                                Obx(
                                                  () => SizedBox(
                                                    height: controller
                                                            .allAttachmentsView
                                                        ? 24.h
                                                        : 50.h,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                      ),
                    ),
                  ),

                  Obx(
                    () => Visibility(
                      visible: controller.forms.isNotEmpty &&
                          (!controller.isFormsCompleted.value) &&
                          (controller.isKeyboardHidden.value) &&
                          (controller.allAttachmentsView),
                      // Pinned "sign & submit" zone — a top hairline + upward
                      // shadow separate it from the form scrolling underneath.
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(top: 10.h),
                        decoration: BoxDecoration(
                          color: context.backgroundColor,
                          border: Border(
                            top: BorderSide(color: context.dividerColor),
                          ),
                          boxShadow: context.bottomBarShadow,
                        ),
                        child: Column(
                          children: [
                            //
                            //
                            // signature view
                            if (controller.isLoading == false)
                              SignatureSectionWidget(
                                controller: controller.signatureController,
                              ).marginSymmetric(horizontal: 20),

                            //
                            //
                            // submit burron
                            if (controller.isLoading == false)
                              const SubmitButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SubmitButton extends GetView<FormsController> {
  const SubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppButton(
        text: 'Save and Continue',
        onPressed: controller.saveAndContinue,
        bgColor: AppColors.primary,
        textColor: AppColors.onPrimary,
        radius: 14,
        width: double.infinity,
        isLoading: controller.isSigning,
      ),
    ).marginOnly(left: 20, right: 20, bottom: 10, top: 10);
  }
}

class _FormAttachmentsView extends GetView<FormsController> {
  final FormEntity form;
  final String attachmentType;
  const _FormAttachmentsView(
      {required this.form, required this.attachmentType});

  @override
  Widget build(BuildContext context) {
    final lable = attachmentType == FormAttachmentType.video
        ? "Videos"
        : attachmentType == FormAttachmentType.otherDocuments
            ? "Other Documents"
            : "Attachments";

    final list = (attachmentType == FormAttachmentType.video)
        ? form.videos
        : (attachmentType == FormAttachmentType.otherDocuments)
            ? form.otherDocuments
            : form.attachments;
    return Obx(
      () => Visibility(
        visible: list.isNotEmpty,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //
            // videos heading
            Text(
              lable,
              style: TextStyle(
                fontSize: 13.sp,
              ),
            ).marginOnly(left: 18, top: 10),

            //
            // videos list
            Obx(() => ListView.separated(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final attachment = list[index];
                    return GestureDetector(
                      onTap: () {
                        controller.updateFormAttachmentStatus(
                            attachment, index, attachmentType);
                      },
                      child: FormAttachmentItemView(
                              attachment: attachment,
                              index: index,
                              attachmentType: attachmentType)
                          .marginSymmetric(
                        vertical: 5,
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider().marginOnly(
                      left: 30,
                    );
                  },
                ).marginOnly(
                  left: 14,
                  right: 14,
                  top: 5,
                ))
          ],
        ),
      ),
    );
  }
}
