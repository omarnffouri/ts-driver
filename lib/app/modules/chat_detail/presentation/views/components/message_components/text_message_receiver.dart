// import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/forwarded_label.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/message_time_view.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/read_more_text.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/reply_message_view.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/widgets/main_chat_container.dart';

class TextMessageReceiver extends GetView<ChatDetailController> {
  final ConversationMessageEntity message;

  const TextMessageReceiver({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    controller.markMessageAsRead(message);

    return MainChatContainer(
      isSender: false,
      padding: const EdgeInsets.all(8),
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
                      color: context.receivedBubbleTextColor, fontSize: 12),
                ).marginOnly(bottom: 2),

              // building a forwaded indicator
              if (message.forwardMessageId != null)
                const ForwardedLabel(isSender: false),

              // building reply view
              if (message.replyOn != null)
                InkWell(
                  onTap: () {
                    controller.findMessageAndScrollToIndex(message.replyOn?.id);
                  },
                  child: ReplyMessageView(
                    message: message.replyOn!,
                    isSenderView: false,
                  ).marginOnly(bottom: 5),
                ),

              // building message text
              Container(
                constraints: BoxConstraints(minWidth: Get.width * 0.10),
                child: ReadMoreText(
                  message.message ?? "",
                  trimLines: 10, // Number of lines to initially display
                  colorClickableText: AppColors.info, // Customize link color
                  trimMode: TrimMode.Line,
                  trimCollapsedText: '... Read more',
                  trimExpandedText: ' Read less',
                  style: TextStyle(
                    color: context.receivedBubbleTextColor,
                    fontSize: 17,
                  ),
                  mention: message.mentions,
                  messageSenderId: message.modelId ?? 0,
                  groupName: controller.userName,
                ),
              )
            ],
          ),
          MessageTimeView(
            message: message,
          )
        ],
      ),
    );
  }
}
