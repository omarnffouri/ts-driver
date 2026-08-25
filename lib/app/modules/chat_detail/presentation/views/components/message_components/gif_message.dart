// GifMessage.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/message_receipt_ticks.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/message_time_view.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/widgets/main_chat_container.dart';

class GifMessage extends GetView<ChatDetailController> {
  final ConversationMessageEntity message;
  const GifMessage({super.key, required this.message});

  bool get isSender => message.modelId.toString() == controller.myId;

  @override
  Widget build(BuildContext context) {
    final att = (message.attachments?.isNotEmpty ?? false)
        ? message.attachments!.first
        : null;

    final url = att?.url?.trim().isNotEmpty == true
        ? att!.url!
        : (message.message ?? '');

    return MainChatContainer(
      isSender: isSender,
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                return Container(
                  height: 150,
                  color: Colors.transparent,
                  child: Center(
                      child: CircularProgressIndicator(
                    color: isSender ? AppColors.onPrimary : AppColors.primary,
                  )),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  width: 120,
                  color: context.dividerColor,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image),
                );
              },
            ),
          ),
          // Time + ticks (read receipts)
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                const Spacer(),
                MessageTimeView(message: message),
                const SizedBox(width: 2),
                if (isSender)
                  MessageReceiptTicks(isSender: isSender, message: message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
