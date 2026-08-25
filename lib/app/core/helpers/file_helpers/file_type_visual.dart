import 'package:flutter/material.dart';

// Broader than FileExtensionHelper, which omits heic/webp from device cameras.
const imageFileExtensions = {
  'jpg',
  'jpeg',
  'png',
  'webp',
  'heic',
  'gif',
  'bmp'
};

bool isImageExtension(String? raw) {
  final value = (raw ?? '').toLowerCase().replaceAll('.', '').trim();
  return imageFileExtensions.contains(value);
}

({IconData icon, String label}) fileTypeOf(String? raw) {
  final value = (raw ?? '').toLowerCase().replaceAll('.', '').trim();
  if (value.isEmpty) {
    return (icon: Icons.insert_drive_file_rounded, label: 'File');
  }
  if (value.contains('pdf')) {
    return (icon: Icons.picture_as_pdf_rounded, label: 'PDF');
  }
  if (value == 'image' || imageFileExtensions.any(value.contains)) {
    return (icon: Icons.image_rounded, label: 'Image');
  }
  if (value.contains('doc')) {
    return (icon: Icons.description_rounded, label: 'Doc');
  }
  if (value.contains('xls') ||
      value.contains('sheet') ||
      value.contains('csv')) {
    return (icon: Icons.table_chart_rounded, label: 'Sheet');
  }
  return (icon: Icons.insert_drive_file_rounded, label: value.toUpperCase());
}
