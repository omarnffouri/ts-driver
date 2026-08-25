import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/forwarded_label.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/message_receipt_ticks.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/read_more_text.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/reply_message_view.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/previewers/chat_video_player.dart';

import 'message_time_view.dart';

class VideoMessage extends GetView<ChatDetailController> {
  final ConversationMessageEntity message;

  const VideoMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: Get.width * 0.75),
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: message.modelId.toString() == controller.myId
            ? context.sentBubbleColor
            : context.receivedBubbleColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(
              message.modelId.toString() == controller.myId ? 0 : 10),
          topLeft: Radius.circular(
              message.modelId.toString() == controller.myId ? 10 : 0),
          bottomLeft: const Radius.circular(10),
          bottomRight: const Radius.circular(10),
        ),
      ),
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

              InkWell(
                onLongPress: () {
                  controller.selectMessage(message);
                },
                onTap: () async {
                  // if message selection enabled then make message selected
                  // else do actions as required
                  // if (controller.isMessageSelectionEnabled) {
                  //   controller.selectMessage(message);
                  //   return;
                  // }
                  // if (message.sendedNow) {
                  //   if (message.media?.isNotEmpty ?? false) {
                  //     if (message.media![0].sendedNow &&
                  //         message.media![0].file != null) {
                  //       OpenFilex.open(message.media![0].file!.path);
                  //     }
                  //   }
                  // } else {
                  //   final fileManager = ChatVideosManager();
                  //   final fileName = fileManager.getFileNameWithExtenshion(
                  //       message.mediaCollection?[0] ?? "/some_file.jhghj");
                  //   if (await fileManager.videoExist(fileName)) {
                  //     OpenFilex.open(
                  //         (await fileManager.getVideo(fileName))!.path);
                  //   }
                  // }

                  try {
                    // if message selection enabled then make message selected
                    // else do actions as required
                    if (controller.isMessageSelectionEnabled) {
                      controller.selectMessage(message);
                      return;
                    }

                    if (message.sendedNow) {
                      if (message.attachments?.isNotEmpty ?? false) {
                        if (message.attachments![0].sendedNow &&
                            message.attachments![0].file != null) {
                          Get.to(
                            ChatVideoPlayer(
                              videoUrl: "",
                              title: "",
                              videoFile: message.attachments![0].file!,
                            ),
                          );
                        } else {
                          Get.to(
                            ChatVideoPlayer(
                              videoUrl: message.attachments![0].url ?? "",
                              title: "",
                            ),
                          );
                        }
                      }
                    } else {
                      final fileName = controller.chatVideosManager.getFileName(
                        message.attachments?[0].url ?? "",
                        withExtension: true,
                      );

                      final videoFile =
                          await controller.chatVideosManager.getFile(fileName);

                      Get.to(
                        ChatVideoPlayer(
                          videoUrl: message.attachments![0].url ?? "",
                          title: "",
                          videoFile: videoFile,
                        ),
                      );
                    }
                  } catch (_) {}
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      /// video thumbnail builder
                      FutureBuilder<Uint8List?>(
                        future: controller.chatVideosThumbnailManager
                            .getVideoThumbnail(
                          url: message.attachments?[0].url ?? "",
                          file: message.attachments?[0].file,
                        ),
                        builder: (BuildContext context,
                            AsyncSnapshot<Uint8List?> snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data != null) {
                              return Image.memory(
                                snapshot.data!,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                                cacheWidth: 600,
                              );
                            } else {
                              return const Icon(
                                Icons.video_file,
                                size: 200,
                                color: AppColors.primary,
                              );
                            }
                          } else if (snapshot.hasError) {
                            return const Icon(
                              Icons.video_file,
                              size: 200,
                              color: AppColors.primary,
                            );
                          } else {
                            return Container(
                              padding: const EdgeInsets.all(85),
                              child: const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  color: AppColors.onPrimary,
                                ),
                              ),
                            );
                          }
                        },
                      ),

                      //
                      //
                      //
                      ///  play button
                      Positioned.fill(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.onPrimary,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              size: 25,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if ((message.message?.isNotEmpty ?? false) &&
                  message.message != "null")
                Container(
                  constraints: const BoxConstraints(maxWidth: 200),
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
