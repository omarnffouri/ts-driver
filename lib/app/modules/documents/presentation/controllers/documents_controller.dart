import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/modules/documents/domain/entities/document_entity.dart';
import 'package:ts_driver/app/modules/documents/domain/usecases/get_all_documents_usecase.dart';
import 'package:ts_driver/app/modules/documents/domain/usecases/upload_documents_usecase.dart';
import 'package:ts_driver/app/core/services/injection_service.dart';

import '../../../../core/data/error/failures.dart';
import '../../../../controllers/auth_controller.dart';
import '../../../../core/helpers/base_use_case.dart';
import '../../../../core/helpers/file_helpers/file_type_visual.dart';
import '../../../../core/widgets/common_widget.dart';

import '../../../../core/utils/functions.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../data/models/upload_document_model.dart';

class DocumentsController extends GetxController {
  final Rx<UserEntity> _user = Get.find<AuthController>().user;
  UserEntity get user => _user.value;

  final getAllDocumentsUseCase = sl<GetAllDocumentsUseCase>();
  final uploadDocumentsUseCase = sl<UploadDocumentsUseCase>();

  final refreshController = RefreshController();

  final RxList<DocumentEntity> docs = RxList<DocumentEntity>();
  RxList<UploadDocumentModel> uploadDocs = RxList<UploadDocumentModel>();

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxBool _isUploading = false.obs;
  bool get isUploading => _isUploading.value;

  @override
  void onInit() {
    super.onInit();
    debugPrint('DocumentsController onInit ');
    getAllDocuments();
  }

  Future<void> getAllDocuments() async {
    uploadDocs.clear();
    try {
      _isLoading(true);
      final result = await getAllDocumentsUseCase.call(const NoParams());
      result.fold((List<DocumentEntity> documents) {
        docs.value = documents;
        uploadDocs.addAll(
          docs
              .map(
                (e) => UploadDocumentModel(
                    id: int.parse(e.id.toString()),
                    hasExpiration: e.requiredDocument != null &&
                        e.requiredDocument?.hasExpiration == true,
                    expirationDate: ''),
              )
              .toList(),
        );
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

  Future<void> uploadDocuments() async {
    final List<UploadDocumentModel> filteredList = uploadDocs
        .where((item) => item.document != null || item.expirationDate != "")
        .toList();

    if (filteredList.isEmpty) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: 'Select file to upload',
      );
      return;
    }

    if (areAllDocsValid(filteredList) == false) {
      return;
    }

    final body = <String, dynamic>{"data": filteredList};
    try {
      _isUploading(true);
      final result = await uploadDocumentsUseCase.call(body);
      result.fold((bool succ) async {
        if (succ) {
          await getAllDocuments();
          // Refresh the shared status so Home/Profile badges update.
          if (Get.isRegistered<HomeController>()) {
            await Get.find<HomeController>().getApplicationState();
          }
          CommonWidgets.showSnackBar(
            title: 'Success'.tr,
            message: 'Documents uploaded successfully.',
            isError: false,
          );
        } else {
          CommonWidgets.showSnackBar(
            title: 'Error'.tr,
            message: 'Something went wrong',
          );
        }
      }, (Failure r) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: r.message,
        );
      });
      _isUploading(false);
    } catch (e) {
      _isLoading.value = false;
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      debugPrint(e.toString());
      _isUploading(false);
    }
  }

  Future<void> chooseFile(String id, {String? title}) async {
    final File? image = await pickFile(title: title);
    if (image != null) {
      final selectedIndex = uploadDocs.indexWhere(
        (element) => element.id.toString() == id.toString(),
      );
      if (selectedIndex != -1) {
        final item = File(image.path);
        final doc = uploadDocs[selectedIndex];
        doc.file = item;
        doc.document = getFileBase64(item);
        doc.extension = getExtension(item.path);
        doc.fileName = getFileName(item.path);
        doc.fileSizeLabel = _formatBytes(item.lengthSync());
        uploadDocs.refresh();
      } else {
        debugPrint('("--- >> Selected state not found in list');
      }
    }
  }

  String getExtension(String path) {
    final String ext = path.split('.').last;
    debugPrint('extension is $ext');
    return ext;
  }

  void setExpiDate(int index, String date) {
    if (index < 0 || index >= uploadDocs.length) return;
    uploadDocs[index].expirationDate = date;
    uploadDocs.refresh();
  }

  bool areAllDocsValid(List<UploadDocumentModel> uploadDocs) {
    for (UploadDocumentModel item in uploadDocs) {
      if (item.expirationDate != "" && item.document == null) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: 'select file to upload',
        );
        return false;
      } else
      //add hasExpr
      if (item.hasExpiration == true &&
          item.expirationDate == "" &&
          item.document != null) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: 'select expiry date',
        );
        return false;
      }
    }
    return true;
  }

  bool hasExpiration(int index) =>
      docs.elementAt(index).requiredDocument != null &&
      docs.elementAt(index).requiredDocument!.hasExpiration == true;

  int get totalCount => docs.length;

  int get readyCount => uploadDocs.where((doc) => doc.file != null).length;

  bool isReady(int index) =>
      index >= 0 && index < uploadDocs.length && uploadDocs[index].file != null;

  void removeFile(int index) {
    if (index < 0 || index >= uploadDocs.length) return;
    final doc = uploadDocs[index];
    doc.document = null;
    doc.extension = null;
    doc.file = null;
    doc.fileName = null;
    doc.fileSizeLabel = null;
    doc.expirationDate = '';
    uploadDocs.refresh();
  }

  String? attachedFileName(int index) => uploadDocs[index].fileName;

  String? attachedFileSize(int index) => uploadDocs[index].fileSizeLabel;

  bool isImageAttachment(int index) =>
      isImageExtension(uploadDocs[index].extension);

  String? expiryDateOf(int index) {
    final date = uploadDocs[index].expirationDate;
    return (date == null || date.isEmpty) ? null : date;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
