import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:device_info_plus/device_info_plus.dart';
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ts_driver/app/core/helpers/file_helpers/file_extension_helper.dart';
import 'package:ts_driver/app/core/helpers/permission_helper.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';

import 'package:path/path.dart' as path;
import 'package:ts_driver/app/modules/shipments/domain/entities/shipment_entity.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../widgets/app_text.dart';
import '../widgets/common_widget.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_extensions.dart';
import 'package:intl/intl.dart' as intl;
import "dart:ui" as ui;

Future<File?> getImage({
  required ImageSource imageSource,
  bool enableSquare = true,
  bool enableOriginal = true,
  bool enable3x2 = true,
}) async {
  try {
    XFile? image;

    // Use the appropriate image-picking method
    if (imageSource == ImageSource.camera) {
      image = await _pickImageFromCamera();
    } else {
      image = await _pickImageFromGallery();
    }

    // If no image is picked, return null
    if (image == null) {
      return null;
    }

    // Convert the image to a File for cropping
    File file = File(image.path);

    // Crop the image
    return file;
  } catch (e) {
    // Handle errors gracefully
    showSnackBar(Get.context!,
        title: "Error", content: "Failed to process image: $e");
    return null;
  }
}

Future<XFile?> _pickImageFromCamera() async {
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    return await _checkAndConvertHeic(image);
  } catch (e) {
    showSnackBar(Get.context!,
        title: "Error", content: "Failed to capture image: $e");
    return null;
  }
}

Future<XFile?> _pickImageFromGallery() async {
  try {
    final ImagePicker picker = ImagePicker();

    // Attempt to pick an image from the gallery
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    // Check if the picked image is null or in HEIC/HEIF format
    return await _checkAndConvertHeic(image);
  } catch (e) {
    // Show error message if something goes wrong
    showSnackBar(Get.context!,
        title: "Error", content: "Failed to pick image: $e");
    return null;
  }
}

Future<XFile?> _checkAndConvertHeic(XFile? image) async {
  if (image == null) return null;

  final String ext = image.path.split('.').last.toLowerCase();
  if (ext == 'heic' || ext == 'heif') {
    return await convertHeicOrHeifToJpeg(image);
  }
  return image;
}

Future<XFile?> convertHeicOrHeifToJpeg(XFile heicOrHeifImage) async {
  try {
    final Uint8List imageBytes = await heicOrHeifImage.readAsBytes();
    final Uint8List jpegBytes = await FlutterImageCompress.compressWithList(
      imageBytes,
      format: CompressFormat.jpeg,
      quality: 70,
    );

    if (jpegBytes.isNotEmpty) {
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = tempDir.path;
      final String tempFileName =
          '${DateTime.now().millisecondsSinceEpoch}.jpeg';
      final File tempFile = File('$tempPath/$tempFileName');
      await tempFile.writeAsBytes(jpegBytes);
      return XFile(tempFile.path);
    }
  } catch (e) {
    showSnackBar(
      Get.context!,
      title: "Error",
      content: "Failed to convert image: $e",
    );
  }
  return null;
}

Future<File?> pickFile({String? title}) async {
  final ImageSource? selectedSource = await showAppBottomSheet<ImageSource>(
    child: cameraBottomSheet(title: title),
  );

  if (selectedSource == null) {
    return null;
  }

  if (selectedSource == ImageSource.camera &&
      !(await PermissionHelper.haveCameraPermission(
          "Grant camera permission in settings to click photos."))) {
    return null;
  }

  return await getImage(imageSource: selectedSource);
}

String getFileName(String filePath) {
  String fileName = path.basename(filePath);
  return fileName;
}

Widget cameraBottomSheet({String? title}) {
  return Builder(
    builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: (title?.isNotEmpty == true) ? title! : 'Add a file'.tr,
            size: 16,
            weight: FontWeight.w600,
            maxLines: 3,
            color: context.primaryTextColor,
          ),
          SizedBox(height: 4.h),
          AppText(
            text: 'Choose where to pick from'.tr,
            size: 12,
            color: context.secondaryTextColor,
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: _SourceTile(
                  icon: Icons.photo_camera_rounded,
                  accent: AppColors.primary,
                  label: 'Camera'.tr,
                  onTap: () => Get.back(result: ImageSource.camera),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _SourceTile(
                  icon: Icons.image_rounded,
                  accent: const Color(0xFF7A4FE0),
                  label: 'Gallery'.tr,
                  onTap: () => Get.back(result: ImageSource.gallery),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.accent,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: context.dividerColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.r,
              height: 56.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
              child: Icon(icon, color: Colors.white, size: 26.r),
            ),
            SizedBox(height: 10.h),
            AppText(
              text: label,
              size: 13,
              weight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ],
        ),
      ),
    );
  }
}

String getFileBase64(File? image) {
  if (image != null) {
    List<int> bytes = image.readAsBytesSync();
    String base64Image = base64.encode(bytes);
    // String base64Image = base64Encode(bytes);
    return base64Image;
  }
  return '';
}

String getSignatureBase64(Uint8List? bytes) {
  if (bytes != null) {
    String base64Image = base64.encode(bytes.toList());
    return base64Image;
  }
  return '';
}

extension Unique<E, Id> on List<E> {
  List<E> unique([Id Function(E element)? id, bool inplace = true]) {
    final ids = <dynamic>{};
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));
    return list;
  }
}

formatedTime({required int timeInSecond}) {
  int sec = timeInSecond % 60;
  int min = (timeInSecond / 60).floor();
  String minute = min.toString().length <= 1 ? "0$min" : "$min";
  String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
  return "$minute:$second";
}

String generateUniqueNumber(int minLength, int maxLength) {
  int min = (minLength < 1) ? 1 : minLength;
  int max = (maxLength < minLength) ? (minLength + 1) : maxLength;

  Random random = Random();
  int length = min + random.nextInt(max - min + 1);

  String result = '';
  for (int i = 0; i < length; i++) {
    result += random.nextInt(10).toString();
  }

  return result;
}

Future<Directory?> getDownloadDirectory() async {
  if (Platform.isAndroid) {
    return await getTemporaryDirectory();
  }
  return await getApplicationDocumentsDirectory();
}

Future<void> saveFile({
  required String url,
  required String fileName,
  required String extension,
}) async {
  if (Platform.isAndroid) {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = deviceInfo.version.sdkInt;
    final storageStatus = sdkInt < 33
        ? await PermissionHelper.haveStoragePermission(
            "Grant storage permission in settings to download files on your device.")
        : true;

    if (!storageStatus) {
      return;
    }
  }

  try {
    Directory? directory = await getDownloadDirectory();
    if (directory == null) {
      debugPrint("saveFile directory is null");
      return;
    }

    File saveFile = File("${directory.path}/$fileName");
    debugPrint(saveFile.path);
    if (await directory.exists()) {
      await Dio().download(
        url,
        saveFile.path,
        onReceiveProgress: (received, total) async {
          debugPrint(
              "Download ${(received / total * 100).toStringAsFixed(0)}%");
          if ((received / total * 100).toStringAsFixed(0) == '100') {
            debugPrint('Download directory: $directory');
            final params = SaveFileDialogParams(
              sourceFilePath: saveFile.path,
              fileName: "$fileName.$extension",
              mimeTypesFilter: getMimeTypesFilter(extension),
            );
            debugPrint("Download params $params");
            final filePickerPath =
                await FlutterFileDialog.saveFile(params: params);
            debugPrint('Download filePath: $filePickerPath');

            // remove the file after saving it
            if (await saveFile.exists()) {
              await saveFile.delete();
            }

            if (filePickerPath == null) return;

            CommonWidgets.showSnackBar(
              title: 'success',
              message: 'File downloaded successfully!',
              isError: false,
            );
          }
        },
      );
    }
  } catch (e) {
    debugPrint('error $e');
  }
}

/// Downloads a remote file to a temp path and opens the system share sheet for
/// it, then cleans up the temp copy. Returns false if the download produced no
/// file. Callers own their own loading/error UI.
Future<bool> shareRemoteFile({required String url, String? subject}) async {
  final fileName = FileExtensionHelper().getFileName(url, withExtension: true);
  final directory = await getTemporaryDirectory();
  final filePath = '${directory.path}/$fileName';

  await Dio().download(url, filePath);

  final file = File(filePath);
  if (!await file.exists()) return false;

  await SharePlus.instance.share(
    ShareParams(
      subject: subject ?? fileName,
      files: [
        XFile(filePath, mimeType: lookupMimeType(filePath), name: fileName)
      ],
    ),
  );
  await file.delete();
  return true;
}

getMimeTypesFilter(String extension) {
  switch (extension) {
    case '.pdf':
      return ['application/pdf'];
    case '.jpg':
      return ['image/jpg'];
    case '.jpeg':
      return ['image/jpeg'];
    case '.png':
      return ['image/png'];
    default:
      return ['application/pdf'];
  }
}

void showSnackBar(
  BuildContext context, {
  required String title,
  required String content,
  bool isErr = true,
  int marinTop = 0,
}) {
  final snackBar = SnackBar(
    elevation: 0,
    duration: const Duration(seconds: 2),
    behavior: SnackBarBehavior.floating,
    backgroundColor: kTransparentColor,
    content: SizedBox(
      height: 80.h,
      child: AwesomeSnackbarContent(
        title: title,
        message: content,
        inMaterialBanner: true,
        color: isErr ? kMainColor : Colors.green,
        contentType: isErr ? ContentType.failure : ContentType.success,
      ),
    ),
    margin: EdgeInsets.only(
      bottom: MediaQuery.of(context).size.height - 280,
      right: 10,
      left: 10,
    ),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}

String idGenerator() {
  final now = DateTime.now();
  return now.microsecondsSinceEpoch.toString();
}

Future<void> openUrl(String url) async {
  try {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      CommonWidgets.showSnackBar(
        title: 'Error',
        message: 'Cannot launch url!'.tr,
      );
    }
  } catch (e, _) {
    CommonWidgets.showSnackBar(
      title: 'Error',
      message: 'Cannot launch url!'.tr,
    );
  }
}

Future<Uint8List> getBytesFromAsset(
    {required String path, required int width}) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
      .buffer
      .asUint8List();
}

Future<dynamic> retrieveFile(
  String baseDir,
  String fileName,
  String filePath,
) async {
  try {
    // Combine the base directory with the file name
    final extension = filePath.split('.').last;
    Directory? directory = await getDownloadDirectory();
    if (directory == null) {
      // Handle the case when external storage directory is not available
      return false;
    }

    String newPath = '${directory.path}/$baseDir';
    directory = Directory(newPath);
    File savedFile = File("${directory.path}/$fileName.$extension");

    // Check if file exists
    if (await savedFile.exists()) {
      // Read the file
      return savedFile; // or readAsStrings() depending on file type
    } else {
      // Handle the case where the file does not exist
      throw Exception('File not found at $filePath');
    }
  } catch (e) {
    // Handle any other exceptions
    throw Exception('Error retrieving file: $e');
  }
}

void showImageDialog(BuildContext context, String imageUrl, {String? title}) {
  showDialog(
    context: context,
    barrierColor: Colors.black,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: SizedBox.expand(
          child: Stack(
            children: [
              // zoomable image on an immersive black canvas
              Positioned.fill(
                child: PhotoView(
                  imageProvider: NetworkImage(imageUrl),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2.5,
                  initialScale: PhotoViewComputedScale.contained,
                  loadingBuilder: (context, event) => Center(
                    child: CircularProgressIndicator(
                      value: event == null || event.expectedTotalBytes == null
                          ? null
                          : event.cumulativeBytesLoaded /
                              event.expectedTotalBytes!,
                      color: AppColors.primary,
                    ),
                  ),
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: Colors.white.withValues(alpha: .6),
                      size: 56.r,
                    ),
                  ),
                ),
              ),
              // top scrim keeps the controls legible over bright photos
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black54, Colors.transparent],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(8.w, 8.h, 12.w, 18.h),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  Colors.black.withValues(alpha: .35),
                              shape: const CircleBorder(),
                            ),
                          ),
                          if ((title ?? '').isNotEmpty) ...[
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                title!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

TextSpan buildAddressTextSpan({
  required LocationEntity? location,
  required Color tripColor,
  DateTime? transitDateTime,
  Color textColor = Colors.black,
  Color dateColor = kTextColor,
}) {
  TextStyle boldStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  TextStyle tripColorStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: tripColor,
  );

  List<TextSpan> children = [];

  // Add location details if they are not empty
  if (location?.companyName?.isNotEmpty ?? false) {
    children.add(TextSpan(
      text: '${location?.companyName}, ',
      style: boldStyle,
    ));
  }

  if (location?.address?.isNotEmpty ?? false) {
    children.add(TextSpan(
      text: '${location?.address}, ',
      style: tripColorStyle,
    ));
  }

  if (location?.city?.isNotEmpty ?? false) {
    children.add(TextSpan(
      text: '${location?.city}, ',
      style: boldStyle,
    ));
  }

  if (location?.stateName?.isNotEmpty ?? false) {
    children.add(TextSpan(
      text: '${location?.stateName}.',
      style: boldStyle,
    ));
  }

  // Add transit date-time only when it's available.
  if (transitDateTime != null) {
    children.add(TextSpan(
      text:
          "\n${intl.DateFormat('yyyy-MM-dd hh:mm a').format(transitDateTime)}",
      style: TextStyle(
        fontSize: 14,
        color: dateColor,
      ),
    ));
  }

  return TextSpan(children: children);
}
