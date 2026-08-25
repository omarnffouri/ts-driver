import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/theme/app_colors.dart';

/// Explains why the app needs microphone access (receiving and making calls)
/// before triggering the actual system permission request.
///
/// Shown when the main screen opens after login and the microphone
/// permission hasn't been granted yet (see [MainScreenController.onReady]).
/// Closes with `true` when the user agrees to continue, `false` when
/// dismissed.
class MicPermissionDialog extends StatelessWidget {
  const MicPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff242424) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.applyOpacity(0.25),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //
            //
            // gradient badge
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColorsLight.mainColorLight,
                    AppColorsLight.mainColorDark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColorsLight.mainColor.applyOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.mic_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),

            //
            //
            // title + short intro
            Text(
              "Never miss a call",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ).marginOnly(top: 18),

            Text(
              "Allow microphone access to receive and make calls.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ).marginOnly(top: 6),

            //
            //
            // gradient continue button
            Material(
              color: Colors.transparent,
              child: Ink(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [
                      AppColorsLight.mainColorLight,
                      AppColorsLight.mainColorDark,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorsLight.mainColor.applyOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Get.back(result: true);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Allow Access",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).marginOnly(top: 24),

            //
            //
            // dismiss option
            TextButton(
              onPressed: () {
                Get.back(result: false);
              },
              child: Text(
                "Maybe later",
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ).marginOnly(top: 4),
          ],
        ),
      ),
    );
  }
}
