import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';

/// A small rounded "disc" holding a tinted icon — the shared leading visual for
/// list rows across the app (settings, profile, notifications). Centralizes the
/// disc tint (12%) so the look stays consistent as more screens adopt it.
///
/// Provide either an [icon] (Material) or an [svgAsset] path.
class AppIconDisc extends StatelessWidget {
  const AppIconDisc({
    super.key,
    required this.color,
    this.icon,
    this.svgAsset,
    this.size = 40,
    this.iconSize = 20,
    this.radius = 11,
    this.circle = false,
  }) : assert(icon != null || svgAsset != null,
            'AppIconDisc needs either an icon or an svgAsset');

  final Color color;
  final IconData? icon;
  final String? svgAsset;
  final double size;
  final double iconSize;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: color.applyOpacity(0.12),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius.r),
      ),
      child: Center(
        child: svgAsset != null
            ? SvgPicture.asset(
                svgAsset!,
                width: iconSize.w,
                height: iconSize.w,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              )
            : Icon(icon, size: iconSize.sp, color: color),
      ),
    );
  }
}
