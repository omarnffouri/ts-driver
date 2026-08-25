import 'package:flutter/material.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

/// "Forwarded" indicator row shown atop a forwarded message bubble.
class ForwardedLabel extends StatelessWidget {
  final bool isSender;
  const ForwardedLabel({super.key, required this.isSender});

  @override
  Widget build(BuildContext context) {
    final color =
        isSender ? AppColors.onPrimary : context.receivedBubbleTextColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.flip(
          flipX: true,
          child: Icon(Icons.reply_rounded, color: color, size: 20),
        ),
        Text(
          "Forwarded",
          style: TextStyle(color: color, fontSize: 12),
        ),
      ],
    );
  }
}
