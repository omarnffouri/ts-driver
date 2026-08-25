import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/helpers/file_helpers/file_opener.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';

import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/forwarded_label.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/message_receipt_ticks.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/message_time_view.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/read_more_text.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/reply_message_view.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/widgets/main_chat_container.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../domain/entities/conversation_details_entity.dart';

class DocumentMessage extends GetView<ChatDetailController> {
  final ConversationMessageEntity message;
  const DocumentMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final attachment = message.attachments![0];

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

              GestureDetector(
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
                  try {
                    if (message.sendedNow) {
                      if (message.attachments?.isNotEmpty ?? false) {
                        if (attachment.sendedNow && attachment.file != null) {
                          final file = File(message.attachments![0].file!.path);
                          await launchUrl(Uri.file(file.path));
                          // OpenFilex.open(message.attachments![0].file!.path);
                        }
                      }
                    } else {
                      final filePath =
                          await controller.chatDocumentsManager.getDocumentFile(
                        message.attachments?[0].url ?? "",
                        onReceiveProgress: (received, total) {
                          attachment.isDownloading.value = true;
                          attachment.downloadProgress.value =
                              (received / total);
                        },
                      );

                      attachment.isDownloading.value = false;
                      if (filePath != null) {
                        attachment.file = File(filePath);
                        await FileOpener.openFile(filePath);
                      }
                    }
                  } catch (_) {}
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //
                    //
                    // progress and download icon

                    Stack(
                      children: [
                        //
                        //
                        // file icon
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: message.modelId.toString() == controller.myId
                                ? AppColors.onPrimary.withValues(alpha: 0.30)
                                : context.receivedBubbleTextColor
                                    .withValues(alpha: 0.30),
                          ),
                          child: Image.asset(
                            controller.chatDocumentsManager.getFileIcon(
                              controller.chatDocumentsManager.getFileType(
                                message.attachments![0].url ?? "",
                              ),
                            ),
                            width: 25,
                            height: 25,
                          ),
                        ),
                        //
                        //
                        //
                        Obx(
                          () => Visibility(
                            visible: ((!attachment.isDownloading.value) ||
                                !message.sendedNow ||
                                (attachment.file == null)),
                            child: FutureBuilder<bool>(
                              future: controller.chatDocumentsManager.fileExist(
                                controller.fileExtensionHelper.getFileName(
                                  message.attachments?[0].url ?? "",
                                  withExtension: true,
                                ),
                              ),
                              builder: (BuildContext context,
                                  AsyncSnapshot<bool> snapshot) {
                                if (snapshot.connectionState !=
                                        ConnectionState.waiting &&
                                    snapshot.hasData) {
                                  return Visibility(
                                    visible: !(snapshot.data ?? false),
                                    child: GestureDetector(
                                      onTap: () async {
                                        //
                                        // getting doc file
                                        final filePath = await controller
                                            .chatDocumentsManager
                                            .getDocumentFile(
                                          message.attachments?[0].url ?? "",
                                          onReceiveProgress: (received, total) {
                                            attachment.isDownloading.value =
                                                true;
                                            attachment.downloadProgress.value =
                                                (received / total);
                                          },
                                        );

                                        attachment.isDownloading.value = false;
                                        if (filePath != null) {
                                          attachment.file = File(filePath);
                                        }
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black54,
                                        ),
                                        child: Icon(
                                          Icons.download,
                                          size: 25,
                                          color: message.modelId.toString() ==
                                                  controller.myId
                                              ? AppColors.onPrimary
                                              : context.receivedBubbleTextColor,
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(
                                      color: message.modelId.toString() ==
                                              controller.myId
                                          ? AppColors.onPrimary
                                          : context.receivedBubbleTextColor,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),

                        //
                        //
                        // download progress indicator
                        Obx(
                          () => attachment.isDownloading.value
                              ? CircularProgressIndicator(
                                  value: attachment.downloadProgress.value,
                                  strokeCap: StrokeCap.round,
                                  color: message.modelId.toString() ==
                                          controller.myId
                                      ? AppColors.onPrimary
                                      : context.receivedBubbleTextColor,
                                )
                              : const SizedBox(),
                        )
                      ],
                    ),
                    //
                    //
                    // file name
                    Container(
                      constraints: BoxConstraints(maxWidth: Get.width * 0.40),
                      child: Text(
                        controller.fileExtensionHelper.getFileName(
                          message.attachments![0].url ?? "",
                          withExtension: true,
                        ),
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 14,
                          color: message.modelId.toString() == controller.myId
                              ? AppColors.onPrimary
                              : context.receivedBubbleTextColor,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
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
