import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_dialog.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/modules/auth/presentation/login/controllers/login_controller.dart';
import 'package:ts_driver/app/modules/auth/presentation/login/views/bottom_sheets/login_bottom_sheet.dart';
import 'package:ts_driver/app/modules/auth/presentation/login/views/components/slider_widget.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          RoleSliderWidget(
            pageController: controller.pageController.value,
          ),
          addVerticalSpace(Get.height * 0.05),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Hello Captain,',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          addVerticalSpace(Get.height * 0.01),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton.icon(
              onPressed: () {
                showLoginSheet(context);
              },
              icon: SvgPicture.asset(
                Assets.svg.user,
                width: 18.w,
                colorFilter: const ColorFilter.mode(
                  kMainColor,
                  BlendMode.srcIn,
                ),
              ),
              label: const Text(
                'Login',
                style: TextStyle(fontSize: 17),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              onPressed: () {
                showBottomSheetDialog(
                  context: Get.context!,
                  title: AppText(
                    text: 'Select Job Category',
                    color: context.primaryTextColor,
                    weight: FontWeight.bold,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: SvgPicture.asset(
                Assets.svg.register,
                width: 18.w,
              ),
              label: const Text(
                'Register',
                style: TextStyle(fontSize: 17),
              ),
            ),
          ),
          addVerticalSpace(Get.height * 0.08),
          SizedBox(
            height: 80,
            child: Lottie.asset(
              Assets.json.registerTruck,
              repeat: true,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
