import 'dart:io';

class MediaPickerPreviewerParams {
  final List<File> files;
  final bool enableEditing;
  final bool enableCompression;

  MediaPickerPreviewerParams({
    required this.files,
    required this.enableEditing,
    required this.enableCompression,
  });
}
