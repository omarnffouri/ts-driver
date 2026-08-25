import 'package:flutter/material.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/utils/chat_icons.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';

/// Read-receipt indicator for a chat message: blue read-ticks asset when read,
/// a pending clock while sending, otherwise grey/white double-checks. Tick
/// colour follows the bubble side (white on the red sent bubble).
class MessageReceiptTicks extends StatelessWidget {
  final bool isSender;
  final ConversationMessageEntity message;
  const MessageReceiptTicks({
    super.key,
    required this.isSender,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (message.readAt != null && message.readAt != "null") {
      return Image.asset(ChatIcons.readIcon, width: 15, height: 15);
    }
    final color = isSender ? AppColors.onPrimary : context.receiptTickColor;
    if (message.sendedNow && !message.sentSuccessfully) {
      return Icon(Icons.timelapse_rounded, size: 12, color: color);
    }
    return Stack(
      children: [
        Positioned.fill(
          left: 4,
          child: Icon(Icons.check, size: 12, color: color),
        ),
        Icon(Icons.check, size: 12, color: color),
      ],
    );
  }
}
