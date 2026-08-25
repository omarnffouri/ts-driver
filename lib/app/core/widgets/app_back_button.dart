import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// Standard header back button: an [Icons.arrow_back_rounded] glyph with a
/// circular tap ripple. Drop-in replacement for the bare `GestureDetector` +
/// `Icon` back buttons used across module headers (which had no tap feedback).
///
/// [onTap] defaults to [Get.back]; override [icon]/[size]/[color] for the rare
/// variants. The glyph keeps its raw footprint (no extra padding) so existing
/// surrounding margins still position it the same — only the ripple is added.
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onTap,
    this.color = Colors.white,
    this.size = 30,
    this.icon = Icons.arrow_back_rounded,
  });

  final VoidCallback? onTap;
  final Color color;
  final double size;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap ?? Get.back,
        radius: 26.r,
        child: Icon(icon, size: size, color: color),
      ),
    );
  }
}
