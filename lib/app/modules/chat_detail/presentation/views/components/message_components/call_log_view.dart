import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/call_log_icon.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/message_time_view.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/reply_message_view.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/widgets/main_chat_container.dart';

class CallLogMessage extends GetView<ChatDetailController> {
  final ConversationMessageEntity message;
  const CallLogMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MainChatContainer(
      isSender: message.modelId.toString() == controller.myId,
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

              // building reply view
              if (message.replyOn != null)
                InkWell(
                  onTap: () {
                    controller.findMessageAndScrollToIndex(message.replyOn?.id);
                  },
                  child: ReplyMessageView(
                    message: message.replyOn!,
                    isSenderView: message.modelId.toString() == controller.myId,
                  ).marginOnly(bottom: 5, right: 5, left: 5),
                ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // call log icon
                  CallLogIcon(message: message, width: 25, height: 25),

                  // caller or reciver name
                  Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.callType == "video"
                              ? "Video Call"
                              : "Audio Call",
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: message.modelId.toString() == controller.myId
                                ? AppColors.onPrimary
                                : context.receivedBubbleTextColor,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          controller.getCallText(
                              message.modelId,
                              message.message ?? AgoraCallEvents.incommingCall,
                              message.duration),
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: 14,
                            color: message.modelId.toString() == controller.myId
                                ? AppColors.onPrimary
                                : context.receivedBubbleTextColor,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
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
