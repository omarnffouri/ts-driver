import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../controllers/media_picker_previewer_controller.dart';

class ImageEditorBottomSheet extends StatefulWidget {
  final MediaPickerFile mediaPickerFile;
  const ImageEditorBottomSheet({
    super.key,
    required this.mediaPickerFile,
  });

  @override
  State<ImageEditorBottomSheet> createState() => _ImageEditorBottomSheetState();
}

class _ImageEditorBottomSheetState extends State<ImageEditorBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: ProImageEditor.file(
        widget.mediaPickerFile.orignalFile,
        // controller.mediaFiles.elementAt(0).orignalFile,
        configs: ProImageEditorConfigs(
          stateHistory: widget.mediaPickerFile.editHistory != null
              ? StateHistoryConfigs(
                  initStateHistory: ImportStateHistory.fromMap(
                    widget.mediaPickerFile.editHistory!,
                  ),
                )
              : const StateHistoryConfigs(),
        ),
        callbacks: ProImageEditorCallbacks(
          onImageEditingComplete: (Uint8List bytes) async {
            widget.mediaPickerFile.editedFile.value = bytes;
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
