import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/forwarded_label.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/message_receipt_ticks.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/message_time_view.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/read_more_text.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/reply_message_view.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/widgets/main_chat_container.dart';

class ImageMessage extends GetView<ChatDetailController> {
  final ConversationMessageEntity message;

  const ImageMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MainChatContainer(
      isSender: message.modelId.toString() == controller.myId,
      padding: const EdgeInsets.all(2),
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
                ).marginOnly(bottom: 2, left: 5, top: 5),

              // building a forwaded indicator
              if (message.forwardMessageId != null)
                ForwardedLabel(
                  isSender: message.modelId.toString() == controller.myId,
                ),

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

              InkWell(
                onLongPress: () {
                  controller.selectMessage(message);
                },
                onTap: () async {
                  // if message selection enabled then make message selected
                  // else do actions as required
                  if (controller.isMessageSelectionEnabled) {
                    controller.selectMessage(message);
                    return;
                  }
                  controller.onImageClicked(message.attachments?[0].url,
                      message.attachments?[0].file);
                },
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: message.sendedNow
                        ? Image.file(
                            message.attachments![0].file!,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                            cacheWidth: 600,
                          )
                        : Image(
                            image: ResizeImage(
                              CachedNetworkImageProvider(
                                message.attachments?[0].url ?? "",
                              ),
                              width: 600,
                            ),
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.image,
                              size: 200,
                            ),
                          ),
                  ),
                ),
              ),
              if ((message.message?.isNotEmpty ?? false) &&
                  message.message != "null")
                Container(
                  width: 200,
                  padding: const EdgeInsets.all(8),
                  child: ReadMoreText(
                    message.message ?? "",
                    trimLines: 10, // Number of lines to initially display
                    colorClickableText: AppColors.info, // Customize link color
                    trimMode: TrimMode.Line,
                    trimCollapsedText: '... Read more',
                    trimExpandedText: ' Read less',
                    style: TextStyle(
                      color: message.modelId.toString() == controller.myId
                          ? AppColors.onPrimary
                          : context.receivedBubbleTextColor,
                      fontSize: 16,
                    ),
                    mention: message.mentions,
                    messageSenderId: message.modelId ?? 0,
                    groupName: controller.userName,
                  ),
                ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 2, right: 5, bottom: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MessageTimeView(
                  message: message,
                ),
                const SizedBox(
                  width: 2,
                ),
                if (message.modelId.toString() == controller.myId)
                  MessageReceiptTicks(isSender: true, message: message)
              ],
            ),
          )
        ],
      ),
    );
  }
}
