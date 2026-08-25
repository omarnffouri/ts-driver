import 'package:get/get.dart';

import '../controllers/media_picker_previewer_controller.dart';

class MediaPickerPreviewerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MediaPickerPreviewerController>(
      MediaPickerPreviewerController(),
    );
  }
}
