// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ts_driver/app/core/gen/fonts.gen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/core/utils/input_utils.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

import '../../modules/auth/domain/entities/user_entity.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_extensions.dart';
import '../utils/functions.dart';
import '../utils/widget_utils.dart';
import 'app_dialog.dart';
import 'app_text.dart';

/// Shared themed status dialog (success / error / info): a pop-in panel with a
/// tinted circular [icon] badge, [title], optional [pill] + [message], a primary
/// button, and an optional secondary (outlined) button. [badgeColor] tints the
/// badge / pill / hairline; the primary button defaults to the brand red.
Future<bool?> statusDialog({
  required Color badgeColor,
  required IconData icon,
  required String title,
  double titleSize = 20,
  String? pill,
  String? message,
  Color buttonColor = AppColors.primary,
  String primaryText = 'OK',
  VoidCallback? onPrimary,
  String? secondaryText,
  VoidCallback? onSecondary,
  bool barrierDismissible = true,
}) {
  return showDialog<bool>(
    context: Get.context!,
    barrierDismissible: barrierDismissible,
    builder: (context) {
      final dialog = _DialogPopIn(
        child: Dialog(
          backgroundColor: context.panelColor,
          surfaceTintColor: kTransparentColor,
          insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
            side: BorderSide(color: badgeColor.withValues(alpha: 0.35)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    height: 72.r,
                    width: 72.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: badgeColor, size: 40.r),
                  ),
                ),
                addVerticalSpace(18.h),
                AppText(
                  text: title,
                  textAlign: TextAlign.center,
                  weight: FontWeight.bold,
                  size: titleSize,
                  color: context.strongTextColor,
                ),
                if (pill != null) ...[
                  addVerticalSpace(10.h),
                  Center(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: AppText(
                        text: pill,
                        weight: FontWeight.w600,
                        size: 14,
                        color: badgeColor,
                      ),
                    ),
                  ),
                ],
                if (message != null) ...[
                  addVerticalSpace(18.h),
                  AppText(
                    text: message,
                    textAlign: TextAlign.center,
                    size: 13,
                    height: 1.4,
                    color: context.secondaryTextColor,
                  ),
                ],
                addVerticalSpace(28.h),
                SizedBox(
                  height: 52.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: kWhiteColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    onPressed:
                        onPrimary ?? () => Navigator.of(context).pop(true),
                    child: AppText(
                      text: primaryText,
                      color: kWhiteColor,
                      size: 16,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
                if (secondaryText != null) ...[
                  addVerticalSpace(12.h),
                  SizedBox(
                    height: 52.h,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.secondaryTextColor,
                        side: BorderSide(color: context.dividerColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      onPressed:
                          onSecondary ?? () => Navigator.of(context).pop(false),
                      child: AppText(
                        text: secondaryText,
                        color: context.secondaryTextColor,
                        size: 16,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
      return barrierDismissible
          ? dialog
          : PopScope(canPop: false, child: dialog);
    },
  );
}

class CommonWidgets {
  Future<bool?> showSuccessDialog({
    required UserEntity user,
    String? cancelActionText,
    String defaultActionText = 'OK',
  }) {
    final appId = '${user.personalDetails?.applicantId ?? ''}';
    return statusDialog(
      badgeColor: AppColors.success,
      icon: Icons.check_circle_rounded,
      title: 'Registration Successful',
      pill: appId.isEmpty ? null : 'Application #$appId',
      message:
          "Well-done! Your registration has been submitted successfully. Thank you for choosing to be part of our community. We appreciate your interest and look forward to serving you.",
      primaryText: defaultActionText,
      secondaryText: cancelActionText,
    );
  }

  static Future<dynamic> buildHoldRejectDialog(String type, String message) {
    final bool isTerminated = type == "TERMINATED";
    final bool isHold = type.toUpperCase().contains("HOLD");

    // Amber reads as "paused / temporary", brand red as "blocked / final".
    final Color accent = isHold ? kAmberColor : kMainColor;
    final IconData statusIcon =
        isHold ? Icons.pause_circle_outline_rounded : Icons.cancel_outlined;

    return Get.dialog(
      Builder(
        builder: (context) => _DialogPopIn(
          child: Dialog(
            backgroundColor: context.panelColor,
            surfaceTintColor: kTransparentColor,
            insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
              // Accent-tinted hairline frames the panel against the backdrop.
              side: BorderSide(color: accent.withValues(alpha: 0.35)),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      height: 72.r,
                      width: 72.r,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(statusIcon, color: accent, size: 38.r),
                    ),
                  ),
                  addVerticalSpace(18.h),
                  const AppText(
                    text: 'Oopsss!',
                    textAlign: TextAlign.center,
                    weight: FontWeight.bold,
                    size: 26,
                    color: kMainColor,
                  ),
                  addVerticalSpace(8.h),
                  AppText(
                    text: 'Your account is',
                    textAlign: TextAlign.center,
                    size: 14,
                    color: context.secondaryTextColor,
                  ),
                  addVerticalSpace(10.h),
                  // High-emphasis status pill so the state stands out.
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: AppText(
                        text: type,
                        weight: FontWeight.bold,
                        size: 16,
                        color: accent,
                      ),
                    ),
                  ),
                  if (!isTerminated) ...[
                    addVerticalSpace(18.h),
                    AppText(
                      text: message,
                      textAlign: TextAlign.center,
                      size: 13,
                      height: 1.4,
                      color: context.secondaryTextColor,
                    ),
                  ],
                  addVerticalSpace(28.h),
                  SizedBox(
                    height: 52.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: kWhiteColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      onPressed: () async {
                        if (isTerminated) {
                          Get.back();
                          Get.back();
                          await showBottomSheetDialog(
                            context: Get.context!,
                            title: const AppText(
                              text: 'Select Job Category',
                              color: kTextColor,
                              weight: FontWeight.bold,
                            ),
                          );
                        } else {
                          await openChat();
                        }
                      },
                      child: AppText(
                        text: isTerminated ? 'Reapply' : 'Notify HR',
                        color: kWhiteColor,
                        size: 16,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                  addVerticalSpace(12.h),
                  SizedBox(
                    height: 52.h,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.secondaryTextColor,
                        side: BorderSide(color: context.dividerColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: AppText(
                        text: 'No',
                        color: context.secondaryTextColor,
                        size: 16,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: !isTerminated,
    );
  }

  static Future<void> openChat() async {
    const String whatsapp = "+13139086799";
    const String whatsappURlAndroid =
        "whatsapp://send?phone=$whatsapp&text=Hi, I'm Driver";
    const String whatappURLIos = "https://wa.me/$whatsapp?text=Hi, I'm Driver";

    if (Platform.isIOS) {
      // for iOS phone only
      var encoded = Uri.encodeFull(whatappURLIos);
      await openUrl(encoded);
    } else {
      var encoded = Uri.encodeFull(whatsappURlAndroid);
      await openUrl(encoded);
    }
  }

  static void showSnackBar(
      {required String title,
      required String message,
      bool isError = true,
      Duration duration = const Duration(seconds: 3)}) {
    if (Get.isSnackbarOpen) {
      return;
    }
    Get.snackbar(
      title,
      message,
      titleText: AppText(
        text: title,
        color: kWhiteColor,
      ),
      messageText: AppText(
        text: message,
        color: kWhiteColor,
        size: 15,
      ),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.only(
        top: 10.h,
        left: 10.w,
        right: 10.w,
      ),
      backgroundColor: isError ? Colors.red : kGreyColor,
      padding: REdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      duration: duration,
    );
  }
}

class CustomTextFieldWidget extends StatefulWidget {
  const CustomTextFieldWidget({
    super.key,
    this.titleText = '',
    this.titleTextAlign = TextAlign.center,
    required this.validatorMsg,
    required this.hintText,
    required this.labelText,
    this.suffixIcon,
    this.prefixIcon,
    this.obsecure = false,
    this.readOnly = false,
    this.isRequired = true,
    this.textInputAction = TextInputAction.next,
    required this.textController,
    this.inputFormater,
    this.initialvalue,
    this.keyboardType,
    this.onChange,
    this.onsave,
  });

  final String titleText;
  final TextAlign titleTextAlign;
  final bool obsecure;
  final String validatorMsg;
  final String hintText;
  final String labelText;
  final dynamic suffixIcon;
  final dynamic prefixIcon;
  final bool readOnly;
  final bool isRequired;
  final TextInputAction textInputAction;
  final TextEditingController textController;
  final String? initialvalue;
  final Function(String val)? onChange;
  // ignore: prefer_typing_uninitialized_variables
  final inputFormater;
  final TextInputType? keyboardType;
  final Function(String val)? onsave;

  @override
  _CustomTextFieldWidgetState createState() => _CustomTextFieldWidgetState();
}

class _CustomTextFieldWidgetState extends State<CustomTextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: (newValue) {
        widget.onsave;
      },
      keyboardType: widget.keyboardType,
      initialValue: widget.initialvalue,
      textInputAction: widget.textInputAction,
      controller: widget.textController,
      validator:
          widget.keyboardType == TextInputType.emailAddress && widget.isRequired
              ? (val) {
                  final isValid = emailInputValidator(val!);
                  if (val.isEmpty) {
                    return widget.validatorMsg;
                  } else if (isValid) {
                    return null;
                  } else {
                    return 'Enter valid email address';
                  }
                }
              : widget.isRequired
                  ? (value) {
                      if (value!.isEmpty) {
                        return widget.validatorMsg;
                      }
                      return null;
                    }
                  : null,
      inputFormatters: widget.inputFormater,
      onChanged: widget.onChange,
      readOnly: widget.readOnly,
      obscureText: widget.obsecure,
      onTapOutside: (val) {
        FocusScope.of(context).unfocus();
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        errorStyle: TextStyle(fontSize: 13.sp),
        prefixIconColor: AppColorsLight.mainColorLight,
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: widget.readOnly ? context.hintColor : context.primaryTextColor,
          fontSize: 14.sp,
          fontFamily: FontFamily.poppins,
        ),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: context.hintColor,
          fontFamily: FontFamily.poppins,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: context.dividerColor),
          borderRadius: BorderRadius.all(Radius.circular(10.r)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: widget.readOnly ? context.dividerColor : AppColors.primary,
          ),
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      style: TextStyle(
        overflow: TextOverflow.ellipsis,
        fontSize: 14.sp,
        color: widget.readOnly ? context.hintColor : context.primaryTextColor,
      ),
    );
  }
}

class MySeparator extends StatelessWidget {
  const MySeparator({
    Key? key,
    this.height = 1,
    this.color = Colors.grey,
    this.dashWidth = 4.0,
    this.direction = Axis.horizontal,
  }) : super(key: key);
  final double height;
  final double dashWidth;
  final Color color;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashHeight = height.h;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: direction,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}

class ExcitingWidget extends StatelessWidget {
  const ExcitingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          addVerticalSpace(10),
          Image.asset(
            Assets.images.break1.path,
            height: 120,
          ),
          const AppText(
            text: 'Something',
            color: kTextColor,
            weight: FontWeight.w700,
            size: 35,
            height: 1.3,
          ),
          const AppText(
            text: 'Exciting is',
            color: kTextColor,
            weight: FontWeight.w700,
            size: 35,
            height: 1.3,
          ),
          const AppText(
            text: 'Coming!',
            color: kTextColor,
            weight: FontWeight.w700,
            size: 35,
            height: 1.3,
          ),
          const Spacer(),
          Image.asset(
            Assets.images.break2.path,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

class AllSetWidget extends StatelessWidget {
  const AllSetWidget({super.key, required this.title, this.subTitle});
  final String title;
  final String? subTitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(Assets.svg.allSetMark),
          addVerticalSpace(16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    text: title.tr,
                    color: kMainColor,
                    maxLines: 2,
                    weight: FontWeight.bold,
                  ),
                ],
              ),
              addVerticalSpace(4),
              AppText(
                text: subTitle ?? '',
                color: kMainColor,
                maxLines: 2,
                weight: FontWeight.bold,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Plays a subtle scale + fade entrance so dialogs pop in instead of
/// snapping into view. Wrap any dialog child with this.
class _DialogPopIn extends StatefulWidget {
  const _DialogPopIn({required this.child});

  final Widget child;

  @override
  State<_DialogPopIn> createState() => _DialogPopInState();
}

class _DialogPopInState extends State<_DialogPopIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  late final Animation<double> _scale = Tween<double>(
    begin: 0.92,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
