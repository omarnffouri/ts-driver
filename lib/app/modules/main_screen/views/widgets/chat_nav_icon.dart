import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';

class BottomNavIcon extends StatelessWidget {
  final String iconPath;
  final bool isActive;
  final bool showUnreadBadge;
  final RxInt? unreadCount;

  const BottomNavIcon({
    Key? key,
    required this.iconPath,
    required this.isActive,
    this.showUnreadBadge = false,
    this.unreadCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final icon = SizedBox(
      height: 40,
      child: SvgPicture.asset(
        iconPath,
        width: isActive ? 18 : 22,
        height: isActive ? 18 : 22,
        colorFilter: ColorFilter.mode(
          isActive ? AppColorsLight.white : AppColorsLight.senderCallColor,
          BlendMode.srcIn,
        ),
      ),
    );

    if (!showUnreadBadge || unreadCount == null) {
      return Center(child: icon);
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        icon,
        Positioned(
          top: -2,
          right: -10,
          child: Obx(() => Visibility(
                visible: unreadCount!.value > 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : AppColorsLight.mainColor,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    unreadCount!.value > 99
                        ? "99+"
                        : unreadCount!.value.toString(),
                    style: TextStyle(
                      color: isActive
                          ? AppColorsLight.mainColor
                          : AppColorsLight.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )),
        ),
      ],
    );
  }
}
