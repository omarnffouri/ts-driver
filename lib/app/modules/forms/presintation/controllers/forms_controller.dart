// ignore_for_file: invalid_use_of_protected_member

import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:signature/signature.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/core/helpers/message_file_helper.dart';
import 'package:ts_driver/app/core/widgets/file_viewer.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/previewers/chat_image_preview.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/previewers/chat_video_player.dart';
import 'package:ts_driver/app/modules/forms/domain/entities/form_entity.dart';
import 'package:ts_driver/app/modules/forms/domain/usecases/update_form_attachment_status.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../controllers/auth_controller.dart';
import '../../../../core/helpers/signature_helper.dart';
import '../../../../core/services/injection_service.dart';
import '../../../../core/widgets/common_widget.dart';
import '../../../../core/data/error/failures.dart';
import '../../../../core/utils/functions.dart';
import '../../domain/entities/sign_form_entity.dart';
import '../../domain/usecases/get_all_forms_usecase.dart';
import '../../domain/usecases/sign_form_usecase.dart';

class FormsController extends GetxController {
  final user = Get.find<AuthController>().user.value;

  // use cases
  final getAllFormsUsecase = sl<GetAllFormsUsecase>();
  final signFormUsecase = sl<SignFormUsecase>();
  final updateFormAttachmentStatusUsecase = sl<UpdateFormAttachmentUsecase>();

  final ItemScrollController scrollController = ItemScrollController();

  final RxList<FormEntity> _forms = RxList<FormEntity>();
  List<FormEntity> get forms => _forms.value;

  RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );

  //
  //
  // loading state
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  //
  // sigining state
  final RxBool _isSigning = false.obs;
  bool get isSigning => _isSigning.value;

  // updating form attachment statuts state
  final RxBool _isUpdatingAttachmentStatus = false.obs;
  bool get isUpdatingAttachmentStatus => _isUpdatingAttachmentStatus.value;

  final RxBool _allAttachmentsView = false.obs;
  bool get allAttachmentsView => _allAttachmentsView.value;

  //
  final _havePendingForms = false.obs;
  bool get havePendingForms => _havePendingForms.value;

  //
  //
  // forms states
  final activeStep = 0.obs;
  final isFormsCompleted = false.obs;

  final isKeyboardHidden = true.obs;

  final updatingAttachmentStatusAtIndex = (-1).obs;
  final updatingAttachmentStatusType = FormAttachmentType.none.obs;

  //
  //
  final SignatureController signatureController = buildSignatureController();

  @override
  void onInit() {
    super.onInit();
    getAllUserForms();
  }

  void handleRefresh() async {
    await getAllUserForms();
    refreshController.refreshCompleted();
  }

  Future<void> getAllUserForms() async {
    try {
      _forms.clear();
      _isLoading(true);
      final result = await getAllFormsUsecase.call(const NoParams());

      result.fold((List<FormEntity> forms) {
        _forms.value = forms;
        log('forms list length: ${forms.length}');
        if (forms.isEmpty) {
          return;
        }
        // check if there are any pending forms
        _havePendingForms.value = forms.any(
          (element) => !(element.isSigned ?? false),
        );
        // get the current form step
        int firstFalseIndex =
            forms.indexWhere((item) => item.isSigned! == false);
        debugPrint('firstTrueIndex >> $firstFalseIndex');
        if (firstFalseIndex != -1) {
          activeStep.value = firstFalseIndex;
          debugPrint('activeStep.value >> ${activeStep.value}');
        } else {
          activeStep.value = _forms.value.length - 1;
          isFormsCompleted.value = true;
          debugPrint('activeStep.value >> ${activeStep.value}');
        }

        checkAllAttachmentsViewed(forms.elementAt(
          activeStep.value,
        ));
      }, (Failure r) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: r.message,
        );
      });
      _isLoading(false);
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      debugPrint(e.toString());
      _isLoading(false);
    }
  }

  Future<void> saveAndContinue() async {
    final formK = forms.elementAt(activeStep.value).formGlobalKey;
    // check the fields validation
    if (formK.currentState!.validate() == false) {
      debugPrint('is NOT valid ');
      // FocusManager.instance.primaryFocus?.unfocus();
      CommonWidgets.showSnackBar(
        title: 'Error',
        message: 'Some Fields are required!',
      );
      jumpToFirstRequiredField();
      return;
    }

    //check the signature validation
    if (signatureController.isEmpty) {
      debugPrint('error you need to sign first ');
      CommonWidgets.showSnackBar(
        title: 'Error',
        message: 'You need to Sign First',
      );
      return;
    }

    // convert signature to base64
    final Uint8List? bytes = await signatureController.toPngBytes();
    String base64Image = getSignatureBase64(bytes);
    debugPrint(base64Image);

    // prepare text controllers for form data
    List<FormDatumEntity> formData = forms
            .elementAt(activeStep.value)
            .formFields
            ?.where((e) => ((e.type == "string") ||
                (e.type == "textarea") ||
                (e.type == "date")))
            .map((e) => FormDatumEntity(
                fieldId: e.fieldId?.toString(),
                value: e.textEditingController.text.toString()))
            .toList() ??
        [];

    // link controller value with [signFormModel] body key
    final SignFormEntity signForm = SignFormEntity(
      applicantId: user.personalDetails!.applicantId,
      formId: forms.elementAt(activeStep.value).formId,
      applicantFormId: forms.elementAt(activeStep.value).applicantFormId,
      signature: base64Image,
      formData: formData,
    );

    // integrate signed form with backend
    try {
      _isSigning(true);
      final Either<bool, Failure> result =
          await signFormUsecase.call(signForm.toJson());

      result.fold((bool succ) {
        CommonWidgets.showSnackBar(
          title: 'Success'.tr,
          message: 'Form submitted successfully.',
          isError: false,
        );

        //clear the signature pad
        signatureController.clear();

        // going to the next form and update the page
        getAllUserForms();
      }, (Failure r) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: r.message,
        );
      });
      _isSigning(false);
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      _isSigning(false);
    }
  }

  onSubmitTextField(int index) {
    final currentForm = forms.elementAtOrNull(activeStep.value);
    if (currentForm != null) {
      //
      //
      if ((index + 1) < (currentForm.formFields?.length ?? 0)) {
        for (int i = (index + 1);
            i < (currentForm.formFields?.length ?? 0);
            i++) {
          if ((currentForm.formFields![i].type == "string" ||
                  currentForm.formFields![i].type == "textarea") &&
              (currentForm.formFields![i].formFieldsValue?.value.isEmpty ??
                  true)) {
            scrollController.scrollTo(
                index: i, duration: const Duration(milliseconds: 500));
            currentForm.formFields![i].focusNode.requestFocus();
            break;
          }
        }
      }
    }
  }

  void jumpToFirstRequiredField() {
    final currentForm = forms.elementAtOrNull(activeStep.value);
    if (currentForm != null) {
      for (int i = 0; i < (currentForm.formFields?.length ?? 0); i++) {
        if ((currentForm.formFields![i].type == "string" ||
                currentForm.formFields![i].type == "textarea") &&
            (currentForm.formFields![i].textEditingController.text.isEmpty)) {
          scrollController.scrollTo(
              index: i, duration: const Duration(milliseconds: 500));
          currentForm.formFields![i].focusNode.requestFocus();
          break;
        }
      }
    }
  }

  void updateFormAttachmentStatus(FormAttachmentEntity formAttachmentEntity,
      int index, String attachmentType) async {
    try {
      if (attachmentType == FormAttachmentType.video) {
        Get.to(
          ChatVideoPlayer(
            videoUrl: formAttachmentEntity.url!,
            title: formAttachmentEntity.title!,
          ),
        );
      } else {
        final isImageFile = MessageFileHelper.isImageFile(
            lookupMimeType(formAttachmentEntity.url ?? "") ?? "");

        if (isImageFile) {
          Get.to(
            () => ChatImagePreview(
                title: "Form attachment",
                previewImages: [
                  PreviewImage(url: formAttachmentEntity.url, file: null)
                ],
                initialIndex: 0),
          );
        } else if (_isPdfAttachment(formAttachmentEntity.url)) {
          Get.to(
            () => FileViewer(
              title: "Form attachment",
              folderName: "form_docs",
              path: formAttachmentEntity.url!,
              fileLoaded: () {
                //
              },
            ),
          );
        } else {
          await launchUrl(Uri.parse(formAttachmentEntity.url!));
        }
      }
    } catch (_) {}

    if (isUpdatingAttachmentStatus || (formAttachmentEntity.seenAt != null)) {
      return;
    }

    final form = forms.elementAt(
      activeStep.value,
    );

    // formAttachmentEntity.seenAt = DateTime.now();

    try {
      updatingAttachmentStatusAtIndex(index);
      updatingAttachmentStatusType(attachmentType);
      _isUpdatingAttachmentStatus(true);
      _refeshTheList(form, attachmentType);

      final data = {
        'id': formAttachmentEntity.id,
        'type': attachmentType == FormAttachmentType.otherDocuments
            ? FormAttachmentType.attachment
            : attachmentType
      };

      final result = await updateFormAttachmentStatusUsecase.call(data);

      result.fold((bool succ) {
        if (succ) {
          formAttachmentEntity.seenAt = DateTime.now();
        }

        _refeshTheList(form, attachmentType);
        checkAllAttachmentsViewed(form);
      }, (Failure r) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: r.message,
        );
      });

      updatingAttachmentStatusAtIndex(-1);
      updatingAttachmentStatusType(FormAttachmentType.none);
      _isUpdatingAttachmentStatus(false);
      _refeshTheList(form, attachmentType);
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      updatingAttachmentStatusAtIndex(-1);
      updatingAttachmentStatusType(FormAttachmentType.none);
      _isUpdatingAttachmentStatus(false);
      _refeshTheList(form, attachmentType);
    }
  }

  _refeshTheList(FormEntity form, String attachmentType) {
    if (attachmentType == FormAttachmentType.video) {
      form.videos.refresh();
    }
    if (attachmentType == FormAttachmentType.attachment) {
      form.attachments.refresh();
    }
    if (attachmentType == FormAttachmentType.otherDocuments) {
      form.otherDocuments.refresh();
    }
  }

  checkAllAttachmentsViewed(FormEntity form) {
    final allVideosSeen =
        form.videos.firstWhereOrNull((element) => element.seenAt == null) ==
            null;
    final allAttachmentsSeen = form.attachments
            .firstWhereOrNull((element) => element.seenAt == null) ==
        null;
    final allOtherDocumentsSeen = form.otherDocuments
            .firstWhereOrNull((element) => element.seenAt == null) ==
        null;

    _allAttachmentsView(
        allVideosSeen && allAttachmentsSeen && allOtherDocumentsSeen);
  }

  String getAttachmentIcon(String? url) {
    if (url == null) {
      MessageFileHelper.getFileIcon(MessageFileType.none);
    }

    return MessageFileHelper.getFileIcon(MessageFileHelper.getFileType(
        MessageFileHelper.getFileExtension(
            MessageFileHelper.getFileNameWithExtenshion(url!))));
  }

  bool _isPdfAttachment(String? url) {
    if (url == null) {
      false;
    }

    final ext = MessageFileHelper.getFileExtension(
        MessageFileHelper.getFileNameWithExtenshion(url!));

    return ext == "pdf";
  }
}

class FormAttachmentType {
  static const video = "video";
  static const attachment = "attachment";
  static const otherDocuments = "otherDocument";
  static const none = "none";
}
