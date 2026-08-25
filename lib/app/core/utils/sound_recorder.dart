// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:record/record.dart';

class SoundRecorder {
  RecorderController controller = RecorderController();
  final AudioRecorder _audioRecorder = AudioRecorder();

  String _filePath = "";
  String get filePath => _filePath;

  String _basePath = "";
  String get basePath => _basePath;

  Duration _lastRecordingDuration = Duration.zero;
  Timer? _durationTimer;
  DateTime? _recordingStartTime;
  bool _isRecording = false;

  late Function(Duration)? onDurationChanged;

  Duration get duration {
    if (_recordingStartTime != null && _isRecording) {
      return DateTime.now().difference(_recordingStartTime!);
    }
    return _lastRecordingDuration;
  }

  bool get isRecording => _isRecording;

  init() async {
    await _initializePaths();
  }

  Future<void> _initializePaths() async {
    _filePath = await _getTemporaryDirectoryPath();
    if (_filePath.isEmpty) {
      throw Exception("Unable to get temp dir path");
    }
    _basePath = _filePath;

    Directory directory = Directory(_filePath);
    if (!directory.existsSync()) {
      directory.createSync();
    }
  }

  Future<String> _getTemporaryDirectoryPath() async {
    try {
      if (Platform.isIOS) {
        final tempDirectory = await getApplicationDocumentsDirectory();
        return tempDirectory.path;
      } else {
        final tempDirectory = await getTemporaryDirectory();
        return tempDirectory.path;
      }
    } catch (e) {
      debugPrint('Error getting temporary directory: $e');
    }
    return "";
  }

  Future<void> startRecording() async {
    try {
      // 1️⃣ Check permissions
      if (!await _audioRecorder.hasPermission()) return;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final isIOS = Platform.isIOS;
      final fileExt = isIOS ? 'm4a' : 'wav';
      _filePath = '$_basePath/recording_$timestamp.$fileExt';

      // 2️⃣ Configure recording setup
      final recordConfig = isIOS
          ? const RecordConfig(
              encoder: AudioEncoder.aacLc,
              bitRate: 128000,
              sampleRate: 44100,
              numChannels: 1,
            )
          : const RecordConfig(
              encoder: AudioEncoder.wav,
              sampleRate: 44100,
              numChannels: 1,
            );

      // 3️⃣ Start the main audio recording
      await _audioRecorder.start(recordConfig, path: _filePath);

      // 4️⃣ Start waveform visualization (optional but nice to see)
      try {
        final waveformPath = '$_basePath/waveform_temp_$timestamp.m4a';
        await controller.record(
          path: waveformPath,
          androidEncoder: AndroidEncoder.aac,
          androidOutputFormat: AndroidOutputFormat.mpeg4,
          iosEncoder: IosEncoder.kAudioFormatMPEG4AAC,
          sampleRate: 44100,
          bitRate: 48000,
        );
      } catch (e) {
        debugPrint('Waveform controller failed: $e');
      }

      // 5️⃣ Update state and timers
      _recordingStartTime = DateTime.now();
      _lastRecordingDuration = Duration.zero;
      _isRecording = true;
      _startDurationTimer();
    } catch (e, st) {
      debugPrint('❌ Error starting recording: $e');
      debugPrint('$st');
    }
  }

  Future<void> stopRecording() async {
    try {
      _stopDurationTimer();

      if (_recordingStartTime != null) {
        _lastRecordingDuration =
            DateTime.now().difference(_recordingStartTime!);
      }

      final path = await _audioRecorder.stop();
      _isRecording = false;

      if (Platform.isAndroid) {
        try {
          final waveformPath = await controller.stop();

          if (waveformPath != null && waveformPath.isNotEmpty) {
            try {
              final tempFile = File(waveformPath);
              if (await tempFile.exists()) {
                await tempFile.delete();
              }
            } catch (e) {
              debugPrint('Failed to delete temp waveform file: $e');
            }
          }
        } catch (e) {
          debugPrint('Waveform controller stop failed: $e');
        }
      } else {
        await controller.stop();
      }

      if (path != null && path.isNotEmpty) {
        _filePath = path;
      }

      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      _stopDurationTimer();
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_recordingStartTime != null) {
        final currentDuration = DateTime.now().difference(_recordingStartTime!);
        if (onDurationChanged != null) {
          onDurationChanged!(currentDuration);
        }
      }
    });
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  void addDurationChangeListener(Function(Duration) callback) {
    onDurationChanged = callback;
  }

  Future<void> dispose() async {
    _stopDurationTimer();
    await _audioRecorder.dispose();
  }
}
