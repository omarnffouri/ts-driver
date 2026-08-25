import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

import '../../theme/app_colors.dart';

/// Builds the app's signature-pad controller. The one place signature ink
/// branches on brightness (controllers have no BuildContext for the theme
/// extensions): on-screen ink follows the theme's panel tone, while the export
/// is always re-inked black-on-light (the backend stores a legal signature).
SignatureController buildSignatureController() => SignatureController(
      penStrokeWidth: 3,
      penColor: Get.isDarkMode
          ? AppColors.darkSignatureInk
          : AppColors.lightSignatureInk,
      exportPenColor: Colors.black,
      exportBackgroundColor: AppColors.lightSignaturePanel,
    );
