import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

class MainChatContainer extends StatelessWidget {
  final Widget child;
  final bool isSender;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Color? senderColor;
  final Color? receiverColor;
  final BorderRadius? borderRadius;

  const MainChatContainer({
    super.key,
    required this.child,
    required this.isSender,
    this.margin = const EdgeInsets.only(top: 10),
    this.padding = const EdgeInsets.all(10),
    this.senderColor,
    this.receiverColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: Get.width * 0.8),
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: isSender
            ? (senderColor ?? context.sentBubbleColor)
            : (receiverColor ?? context.receivedBubbleColor),
        borderRadius: borderRadius ??
            BorderRadius.only(
              topLeft: const Radius.circular(10),
              topRight: const Radius.circular(10),
              bottomLeft: Radius.circular(isSender ? 12 : 0),
              bottomRight: Radius.circular(isSender ? 0 : 12),
            ),
      ),
      child: child,
    );
  }
}
