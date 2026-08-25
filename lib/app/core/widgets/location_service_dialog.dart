import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/core/utils/rounded_fill_button.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

class LocationServiceDialog extends StatelessWidget {
  const LocationServiceDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //
                //
                Text(
                  "Location Disabled",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Get.isDarkMode
                        ? Colors.white
                        : AppColorsLight.mainColor,
                  ),
                ).marginOnly(top: 30),

                const Spacer(),

                Center(
                  child: Lottie.asset(
                    Assets.json.turnOnLocation,
                    repeat: true,
                    width: Get.width,
                    fit: BoxFit.cover,
                  ),
                ),

                const Spacer(),
              ],
            ),
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38,
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, -1),
                        )
                      ]),
                  child: Column(
                    children: [
                      Text(
                        "Please enable location service from the settings to proceed further.",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ).marginSymmetric(horizontal: 20).marginOnly(top: 30),

                      //
                      //
                      RoundedFillButton(
                        label: "Open Location Settings",
                        onPressed: () async {
                          if (await Geolocator.isLocationServiceEnabled()) {
                            Get.back();
                            return;
                          }
                          Geolocator.openLocationSettings();
                        },
                        backgroundColor: Colors.white,
                        labelColor: AppColorsLight.mainColor,
                      ).marginSymmetric(horizontal: 20, vertical: 40),
                      // InkWell(
                      //   onTap: () {
                      //     Geolocator.openLocationSettings();
                      //   },
                      //   child: Container(
                      //     width: double.infinity,
                      //     height: 70,
                      //     decoration: const BoxDecoration(
                      //       color: AppColorsLight.mainColor,
                      //     ),
                      //     child: const Center(
                      //       child: Text(
                      //         "Open Location Settings",
                      //         style: TextStyle(
                      //           fontWeight: FontWeight.bold,
                      //           fontSize: 16,
                      //           color: Colors.white,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
