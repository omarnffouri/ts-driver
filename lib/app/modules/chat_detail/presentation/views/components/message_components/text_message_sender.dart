// import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/forwarded_label.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/message_receipt_ticks.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/message_time_view.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/read_more_text.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/reply_message_view.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/widgets/main_chat_container.dart';

class TextMessageSender extends GetView<ChatDetailController> {
  final ConversationMessageEntity message;

  const TextMessageSender({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MainChatContainer(
      isSender: true,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // building a forwaded indicator
              if (message.forwardMessageId != null)
                const ForwardedLabel(isSender: true),

              // building reply view
              if (message.replyOn != null)
                InkWell(
                  onTap: () {
                    controller.findMessageAndScrollToIndex(message.replyOn?.id);
                  },
                  child: ReplyMessageView(
                    message: message.replyOn!,
                    isSenderView: true,
                  ),
                ),

              Container(
                constraints: BoxConstraints(minWidth: Get.width * 0.13),
                child: ReadMoreText(
                  message.message ?? "",
                  trimLines: 10, // Number of lines to initially display
                  colorClickableText: AppColors.info, // Customize link color
                  trimMode: TrimMode.Line,
                  trimCollapsedText: '... Read more',
                  trimExpandedText: ' Read less',
                  style: const TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 17,
                  ),
                  mention: message.mentions,
                  messageSenderId: message.modelId ?? 0,
                  groupName: controller.userName,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 2,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MessageTimeView(
                message: message,
              ),
              const SizedBox(
                width: 2,
              ),
              MessageReceiptTicks(isSender: true, message: message)
            ],
          )
        ],
      ),
    );
  }
}
