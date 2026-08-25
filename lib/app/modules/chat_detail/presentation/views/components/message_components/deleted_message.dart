import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/message_time_view.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/widgets/main_chat_container.dart';

import '../../../../domain/entities/conversation_details_entity.dart';

class DeletedMessage extends GetView<ChatDetailController> {
  final ConversationMessageEntity message;
  const DeletedMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isSender = message.modelId.toString() == controller.myId;
    return MainChatContainer(
      isSender: isSender,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.type == "group")
                Text(
                  controller.userName,
                  style: TextStyle(
                    color: isSender
                        ? AppColors.onPrimary
                        : context.receivedBubbleTextColor,
                    fontSize: 12,
                  ),
                ).marginOnly(bottom: 2),

              //
              //
              // deleted text view
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.not_interested_rounded,
                    size: 20,
                    color: isSender
                        ? AppColors.onPrimary
                        : context.receivedBubbleTextColor,
                  ),
                  Text(
                    "This message was deleted.",
                    style: TextStyle(
                      color: message.modelId.toString() == controller.myId
                          ? AppColors.onPrimary
                          : context.receivedBubbleTextColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ).marginOnly(left: 5)
                ],
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MessageTimeView(
                message: message,
              ),
            ],
          )
        ],
      ),
    );
  }
}
