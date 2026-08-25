// ignore_for_file: prefer_final_fields, invalid_use_of_protected_member

import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/modules/forms/domain/entities/signed_form_entity.dart';
import 'package:ts_driver/app/modules/forms/domain/usecases/get_all_signed_forms_usecase.dart';
import 'package:ts_driver/app/core/services/injection_service.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/widgets/common_widget.dart';
import '../../../core/data/error/failures.dart';
import '../../../core/utils/functions.dart';

final _digitsRe = RegExp(r'\d+');

class SignedFormSection {
  const SignedFormSection(this.title, this.items);
  final String title;
  final List<SignedFormEntity> items;
}

class SignedFormsController extends GetxController {
  final user = Get.find<AuthController>().user.value;

  final getAllSignedFormsUsecase = sl<GetAllSignedFormsUsecase>();

  RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );

  RxBool isGrid = true.obs;
  final RxList<SignedFormEntity> _signedForms = RxList<SignedFormEntity>();
  List<SignedFormEntity> get signedForms => _signedForms.value;

  RxList<SignedFormEntity> _filtered = RxList<SignedFormEntity>();
  List<SignedFormEntity> get filtered => _filtered.value;
  set filtered(List<SignedFormEntity> value) => _filtered.value = value;

  final searchController = TextEditingController();

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    getAllSignedForms();
  }

  Future<void> getAllSignedForms() async {
    try {
      _isLoading(true);
      final Either<List<SignedFormEntity>, Failure> result =
          await getAllSignedFormsUsecase.call(const NoParams());
      result.fold((List<SignedFormEntity> forms) {
        forms.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
        _signedForms.value = forms;
        _filtered.value = forms;
        log('signed forms list length: ${forms.length}');
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

  void search(String key) {
    debugPrint(key);
    if (searchController.text.isNotEmpty) {
      filtered = signedForms
          .where((element) =>
              element.formName!.toLowerCase().contains(key.toLowerCase()))
          .toList();
    } else {
      filtered = signedForms;
    }
  }

  /// "Recent" (signed < 30 days ago) then "Earlier", newest first. Bucketed by
  /// [SignedFormEntity.signedAt] not `createdAt` — `createdAt` is the form's
  /// creation date, which stays old even for a just-signed form.
  List<SignedFormSection> get sections {
    const farPast = Duration(days: 1 << 30);
    final dated = [
      for (final form in filtered)
        (form: form, age: _signedAge(form.signedAt) ?? farPast),
    ]..sort((a, b) => a.age.compareTo(b.age));

    final recent = <SignedFormEntity>[];
    final earlier = <SignedFormEntity>[];
    for (final entry in dated) {
      (entry.age.inDays < 30 ? recent : earlier).add(entry.form);
    }

    return [
      if (recent.isNotEmpty) SignedFormSection('Recent', recent),
      if (earlier.isNotEmpty) SignedFormSection('Earlier', earlier),
    ];
  }

  /// Approximate age from a relative "X ago" string; null if unrecognised.
  Duration? _signedAge(String? signedAt) {
    if (signedAt == null) return null;
    final s = signedAt.toLowerCase();
    final n = int.tryParse(_digitsRe.firstMatch(s)?.group(0) ?? '') ?? 1;

    if (s.contains('now') || s.contains('sec')) return Duration(seconds: n);
    if (s.contains('min')) return Duration(minutes: n);
    if (s.contains('hour') || s.contains('hr')) return Duration(hours: n);
    if (s.contains('yesterday')) return const Duration(days: 1);
    if (s.contains('today')) return Duration.zero;
    if (s.contains('day')) return Duration(days: n);
    if (s.contains('week') || s.contains('wk')) return Duration(days: n * 7);
    if (s.contains('month')) return Duration(days: n * 30);
    if (s.contains('year') || s.contains('yr')) return Duration(days: n * 365);
    return null;
  }

  Future<void> downloadForm(SignedFormEntity form) async {
    final url = form.signedFormUrl ?? '';
    if (url.isEmpty) {
      CommonWidgets.showSnackBar(title: 'Error'.tr, message: 'Invalid file.');
      return;
    }
    await saveFile(
      url: url,
      fileName: form.formName ?? 'document',
      extension: _extensionOf(url),
    );
  }

  /// Extension from the URL's last path segment, ignoring the query string
  /// ("…/form.pdf?token=abc" -> "pdf").
  String _extensionOf(String url) {
    final segments = Uri.tryParse(url)?.pathSegments ?? const <String>[];
    final name = segments.isNotEmpty ? segments.last : url;
    final dot = name.lastIndexOf('.');
    return dot >= 0 ? name.substring(dot + 1) : 'pdf';
  }

  Future<void> shareForm(SignedFormEntity form) async {
    final url = form.signedFormUrl ?? '';
    if (url.isEmpty) {
      CommonWidgets.showSnackBar(title: 'Error'.tr, message: 'Invalid file.');
      return;
    }
    try {
      final shared = await shareRemoteFile(url: url, subject: form.formName);
      if (!shared) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: 'Unable to prepare the file for sharing.',
        );
      }
    } catch (_) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: 'Something went wrong while sharing.',
      );
    }
  }
}
