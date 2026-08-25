// import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/helpers/file_helpers/chat_audios_manager.dart';
import 'package:ts_driver/app/core/utils/sound/sound_player.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/forwarded_label.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/message_receipt_ticks.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/message_time_view.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/read_more_text.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/reply_message_view.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/widgets/main_chat_container.dart';

class VoiceMessage extends GetView<ChatDetailController> {
  final ConversationMessageEntity message;

  const VoiceMessage({super.key, required this.message});

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
                ).marginOnly(
                  bottom: 2,
                ),

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

              ChatAudioPlayerView(
                message: message,
                myId: controller.myId,
              ),

              if ((message.message?.isNotEmpty ?? false) &&
                  message.message != "null")
                Container(
                  constraints: BoxConstraints(maxWidth: Get.width * 0.55),
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
              if (message.modelId.toString() == controller.myId)
                MessageReceiptTicks(isSender: true, message: message)
            ],
          )
        ],
      ),
    );
  }
}

class ChatAudioPlayerView extends GetView<ChatDetailController> {
  final ConversationMessageEntity message;
  final String myId;

  final chatAudiosManager = Get.put(ChatAudiosManager());

  ChatAudioPlayerView({super.key, required this.message, required this.myId});

  @override
  Widget build(BuildContext context) {
    final attachment = message.attachments![0];

    return (message.sendedNow || (attachment.file != null))
        ? SoundPlayer(
            message: message,
            myId: controller.myId,
          )
        : FutureBuilder<String?>(
            future: chatAudiosManager.getAudioFile(
              message.attachments![0].url ?? "",
              onReceiveProgress: (received, total) {
                attachment.isDownloading.value = true;
                attachment.downloadProgress.value = (received / total);
              },
            ),
            builder: (context, snapshot) {
              attachment.isDownloading.value = false;

              if (snapshot.data != null) {
                attachment.file = File(snapshot.data!);
                return SoundPlayer(
                  message: message,
                  myId: controller.myId,
                );
              }

              return Row(
                children: [
                  //
                  //
                  // process or progress indicator
                  Obx(
                    () => SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                        value: attachment.isDownloading.value
                            ? attachment.downloadProgress.value
                            : null,
                        color: message.modelId.toString() == controller.myId
                            ? AppColors.onPrimary
                            : context.receivedBubbleTextColor,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  ).marginOnly(right: 10),

                  //
                  //
                  // player line
                  Expanded(
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                          color: message.modelId.toString() == controller.myId
                              ? AppColors.onPrimary
                              : context.receivedBubbleTextColor,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  )
                ],
              ).marginAll(10);
            },
          );
  }
}
