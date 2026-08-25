// ignore_for_file: invalid_use_of_protected_member

import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/modules/videos/domain/entities/video_entity.dart';

import '../../../../../controllers/auth_controller.dart';
import '../../../../../core/data/error/failures.dart';
import '../../../../../routes/app_pages.dart';
import '../../../../../core/services/injection_service.dart';
import '../../../../../core/helpers/base_use_case.dart';
import '../../../../../core/widgets/common_widget.dart';
import '../../../domain/enum/lesson_state.dart';
import '../../../domain/usecases/get_all_videos_usecase.dart';

class VideosController extends GetxController {
  final user = Get.find<AuthController>().user.value;

  final getAllVideosUsecase = sl<GetAllVideosUsecase>();

  final RxList<VideoEntity> _videos = RxList<VideoEntity>();
  List<VideoEntity> get videos => _videos.value;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxBool _completedExpanded = false.obs;
  bool get isCompletedExpanded => _completedExpanded.value;
  void toggleCompleted() => _completedExpanded.toggle();

  /// Re-notify the list after the player mutates a lesson's watched time in
  /// place (same object is shared via route arguments), so the hero/cards
  /// reflect the latest progress without a network round-trip.
  void refreshProgress() => _videos.refresh();

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  Future<void> onInit() async {
    super.onInit();
    getAllVideos();
  }

  // ── Course progress ──────────────────────────────────────────────────────
  int get totalCount => videos.length;
  int get completedCount => videos.where((v) => v.isWatched == true).length;
  double get progressFraction =>
      totalCount == 0 ? 0 : completedCount / totalCount;
  int get progressPercent => (progressFraction * 100).round();

  /// Lesson lifecycle for a positional index (gating is sequential).
  LessonState stateOf(int index) {
    final video = videos[index];
    if (video.isWatched == true) return LessonState.completed;
    final unlocked = index == 0 || videos[index - 1].isWatched == true;
    if (!unlocked) return LessonState.locked;
    return (video.time ?? 0) > 0
        ? LessonState.inProgress
        : LessonState.available;
  }

  /// Splits the course into its three sections in one pass: the first
  /// not-yet-completed lesson (the hero), the locked lessons below it, and the
  /// finished lessons. `current` is null when the course is done or empty.
  ({int? current, List<int> upNext, List<int> completed}) partitionLessons() {
    int? current;
    final upNext = <int>[];
    final completed = <int>[];
    for (var i = 0; i < videos.length; i++) {
      if (videos[i].isWatched == true) {
        completed.add(i);
      } else if (current == null) {
        current = i;
      } else {
        upNext.add(i);
      }
    }
    return (current: current, upNext: upNext, completed: completed);
  }

  void openLesson(int index) {
    if (stateOf(index) == LessonState.locked) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: 'You must complete watching the previous videos',
      );
      return;
    }
    Get.toNamed(Routes.VIDEO_PLAYER, arguments: videos[index]);
  }

  void onRefresh() async {
    await getAllVideos();
    refreshController.refreshCompleted();
  }

  Future<void> getAllVideos() async {
    try {
      _isLoading(true);
      final Either<List<VideoEntity>, Failure> result =
          await getAllVideosUsecase.call(const NoParams());
      result.fold((List<VideoEntity> vids) {
        _videos.value = vids;
        log('getAllVideos list length: ${vids.length}');
      }, (Failure r) {
        CommonWidgets.showSnackBar(
          title: ''.tr,
          message: r.message,
          isError: false,
        );
      });
      _isLoading(false);
    } on Exception catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      debugPrint(e.toString());
      _isLoading(false);
    }
  }
}
