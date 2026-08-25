import 'dart:async';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart' as pl;

import '../../../../../core/data/error/failures.dart';
import '../../../../../core/services/injection_service.dart';
import '../../../data/models/video_model.dart';
import '../../../../../core/widgets/common_widget.dart';
import '../../../domain/usecases/update_video_usecase.dart';
import '../../videos/controllers/videos_controller.dart';

class VideoPlayerController extends GetxController {
  final updateVideoUsecase = sl<UpdateVideoUsecase>();

  final videosController = Get.find<VideosController>();
  Rx<pl.VideoPlayerController> playerController =
      pl.VideoPlayerController.networkUrl(Uri.parse('')).obs;
  final Rxn<VideoModel> video = Rxn<VideoModel>();

  static const List<double> playbackSpeeds = [1.0, 1.25, 1.5, 1.75, 2.0];
  final RxDouble playbackSpeed = 1.0.obs;

  final RxInt videoTime = 0.obs;
  RxBool isInitialLoading = false.obs;
  RxBool isSyncingProgress = false.obs;
  RxBool isPlaying = false.obs;
  RxBool showControls = true.obs;

  RxBool isTimerUpdating = false.obs;

  Timer? timer;
  Timer? _controlsTimer;

  @override
  Future<void> onInit() async {
    super.onInit();
    log('>>>>${DateFormat('yyyy-MM-dd hh:mm').format(DateTime.now())}');
    if (Get.arguments != null) {
      video.value = Get.arguments as VideoModel;
      // Seed progress from the saved time so the details ring shows the resumed
      // position immediately, instead of flashing 0% until the player is ready.
      videoTime.value = video.value?.time ?? 0;
      playerController.value = pl.VideoPlayerController.networkUrl(
        Uri.parse(video.value!.videoFile!),
        videoPlayerOptions: pl.VideoPlayerOptions(),
      );

      // check if the video is watched before
      // if not, update the start date
      if (video.value!.startDate == null) {
        final body = <String, dynamic>{
          "id": video.value!.id,
          "start_date": DateFormat('yyyy-MM-dd').format(DateTime.now())
        };
        await updateVideo(body, showInitialLoading: false);
      }
      playerController.value.addListener(() async {
        isPlaying.value = playerController.value.value.isPlaying;
        final currentSeconds = playerController.value.value.position.inSeconds;
        if (video.value?.isWatched == false &&
            currentSeconds > videoTime.value) {
          videoTime.value = currentSeconds;
        }

        if (isTimerUpdating.value == false) {
          isTimerUpdating.value = true;
          startTimer();
        }
      });
      await playerController.value.initialize();

      // Resume from the saved position before starting playback. Doing this
      // after initialize() (instead of a fragile delayed callback in onReady)
      // guarantees the player is ready, so the seek is never dropped.
      final resumeAt = video.value?.time ?? 0;
      videoTime.value = resumeAt;
      if (resumeAt > 0) {
        await playerController.value.seekTo(Duration(seconds: resumeAt));
      }
      await playerController.value.play();
      _revealControls();
    }
  }

  startTimer() {
    timer = Timer.periodic(const Duration(seconds: 10), (activeTimer) async {
      var currentPosition = playerController.value.value.position;
      var videoDuration = playerController.value.value.duration;
      if (videoDuration.inSeconds == currentPosition.inSeconds &&
          video.value?.finishDate == null) {
        // notify the backend - update time and finish date
        final body = <String, dynamic>{
          "id": video.value!.id,
          "time": videoDuration.inSeconds,
          "finish_date": DateFormat('yyyy-MM-dd').format(DateTime.now())
        };
        await updateVideo(body, showInitialLoading: false);
        video.value!.isWatched = true;
        await videosController.getAllVideos();
        activeTimer.cancel();
        Get.back();
      } else {
        // update the time watched
        if (video.value!.isWatched == false &&
            video.value!.time! < currentPosition.inSeconds) {
          final body = <String, dynamic>{
            "id": video.value!.id,
            "time": currentPosition.inSeconds,
          };
          await updateVideo(body, showInitialLoading: false);
          video.value!.time = currentPosition.inSeconds;
          videoTime.value = currentPosition.inSeconds;
        }
      }
    });
  }

  Future<void> updateVideo(
    Map<String, dynamic> body, {
    bool showInitialLoading = true,
  }) async {
    final loadingState =
        showInitialLoading ? isInitialLoading : isSyncingProgress;

    try {
      loadingState(true);
      final Either<bool, Failure> result = await updateVideoUsecase.call(body);
      result.fold((bool succ) {
        log('updateVideo  $body>> : $succ');
      }, (Failure r) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: r.message,
        );
      });
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      debugPrint(e.toString());
    } finally {
      loadingState(false);
    }
  }

  void rewind10seconds() {
    playerController.value.seekTo(
      playerController.value.value.position - const Duration(seconds: 10),
    );
    _revealControls();
  }

  void rewindOneMinute() {
    playerController.value.seekTo(
      playerController.value.value.position - const Duration(minutes: 1),
    );
    _revealControls();
  }

  void forward10seconds() => _forwardBy(const Duration(seconds: 10));

  void forwardOneMinute() => _forwardBy(const Duration(minutes: 1));

  void _forwardBy(Duration delta) {
    final currentMs = playerController.value.value.position.inMilliseconds;
    seekToMilliseconds((currentMs + delta.inMilliseconds).toDouble());
  }

  String secondsToMinutes(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;

    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String formattedSeconds = remainingSeconds.toString().padLeft(2, '0');

    return '$formattedMinutes:$formattedSeconds';
  }

  void toggleVideoPlayerControls() {
    showControls.value = !showControls.value;
    if (showControls.value) _scheduleHideControls();
  }

  void togglePlayPause() {
    final player = playerController.value;
    if (player.value.isPlaying) {
      player.pause();
      showControls.value = true; // keep controls up while paused
      _controlsTimer?.cancel();
    } else {
      player.play();
      _revealControls();
    }
  }

  void setPlaybackSpeed(double speed) {
    playbackSpeed.value = speed;
    playerController.value.setPlaybackSpeed(speed);
    _revealControls();
  }

  void _revealControls() {
    showControls.value = true;
    _scheduleHideControls();
  }

  void _scheduleHideControls() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (playerController.value.value.isPlaying) {
        showControls.value = false;
      }
    });
  }

  void seekToMilliseconds(double milliseconds) {
    final nextPosition = milliseconds
        .clamp(0.0, maxAllowedSeekMilliseconds().toDouble())
        .toInt();

    playerController.value.seekTo(
      Duration(milliseconds: nextPosition),
    );
    _revealControls();
  }

  int maxAllowedSeekMilliseconds() {
    final durationMilliseconds =
        playerController.value.value.duration.inMilliseconds;

    if (video.value?.isWatched == true || video.value?.finishDate != null) {
      return durationMilliseconds > 0 ? durationMilliseconds : 1;
    }

    final savedMilliseconds = (video.value?.time ?? 0) * 1000;
    final localWatchedMilliseconds = videoTime.value * 1000;
    final watchedMilliseconds = savedMilliseconds > localWatchedMilliseconds
        ? savedMilliseconds
        : localWatchedMilliseconds;

    if (watchedMilliseconds <= 0) {
      return 1;
    }

    if (durationMilliseconds <= 0) {
      return watchedMilliseconds;
    }

    return watchedMilliseconds > durationMilliseconds
        ? durationMilliseconds
        : watchedMilliseconds;
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "${duration.inHours > 0 ? '${duration.inHours}:' : ''}$minutes:$seconds";
  }

  @override
  Future<void> onClose() async {
    playerController.value.dispose();
    timer?.cancel();
    _controlsTimer?.cancel();
    // Reflect the latest watched time in the list when leaving the player.
    videosController.refreshProgress();
    super.onClose();
  }
}
