import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_back_button.dart';
import 'package:ts_driver/app/core/widgets/app_red_header.dart';
import 'package:ts_driver/app/core/widgets/app_screen.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';
import '../controllers/partner_drivers_settelemnts_controller.dart';

class PartnerDriversSettelemntsView
    extends GetView<PartnerDriversSettelemntsController> {
  const PartnerDriversSettelemntsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      child: Scaffold(
        body: Column(
          children: [
            /// HEADER
            AppRedHeader(
              height: kToolbarHeight,
              child: Row(
                children: [
                  addHorizontalSpace(10.w),
                  const AppBackButton(icon: Icons.arrow_back_ios, size: 22),
                  addHorizontalSpace(4.w),
                  const Expanded(
                    child: AppText(
                      text: "Driver Settlement Settings",
                      weight: FontWeight.bold,
                      maxLines: 2,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            /// BODY
            Obx(() {
              if (controller.isLoading.value) {
                return Expanded(
                  child: Center(
                    child: SizedBox(
                      height: 200.h,
                      child: Lottie.asset(Assets.json.pageLoader),
                    ),
                  ),
                );
              }

              if (controller.partnerDrivers.isEmpty) {
                return Expanded(
                  child: Center(
                    child: Text(
                      'No drivers found',
                      style: TextStyle(
                        fontSize: 16,
                        color: context.hintColor,
                      ),
                    ),
                  ),
                );
              }

              return Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  itemCount: controller.partnerDrivers.length,
                  itemBuilder: (context, index) {
                    final driver = controller.partnerDrivers[index];

                    return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: context.tileColor,
                            child: Center(
                                child: Icon(
                              Icons.person,
                              size: 24,
                              color: context.hintColor,
                            )),
                          ),
                          title: Text(
                            driver.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text('ID: ${driver.id}'),
                          trailing: Switch(
                            value: driver.canViewSettlements == 1,
                            activeThumbColor: AppColorsLight.white,
                            activeTrackColor: AppColorsLight.mainColor,
                            inactiveThumbColor: AppColorsLight.mainColor,
                            trackOutlineColor: WidgetStateProperty.all(
                                AppColorsLight.mainColor),
                            onChanged: (val) =>
                                controller.toggleSwitch(index, val),
                          ),
                        ));
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
