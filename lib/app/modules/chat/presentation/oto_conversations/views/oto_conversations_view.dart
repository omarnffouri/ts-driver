import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/helpers/message_file_helper.dart';
import 'package:ts_driver/app/core/utils/functions.dart';
import 'package:ts_driver/app/core/values/constants.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/conversation_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/data/enums/message_types.dart';
import 'package:ts_driver/app/modules/chat_detail/data/models/conversation_details_model.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';
import 'package:ts_driver/app/modules/chat/presentation/conversations/controllers/conversations_controller.dart';
import 'package:ts_driver/app/modules/chat/presentation/conversations/views/components/call_log_conversations_icon.dart';
import 'package:ts_driver/app/modules/chat/presentation/conversations/views/components/conversation_list_skeleton.dart';
import 'package:ts_driver/app/modules/chat/presentation/conversations/views/components/unread_badge.dart';
import 'package:ts_driver/app/routes/app_pages.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/profile_image.dart';

import '../controllers/oto_conversations_controller.dart';

class OtoConversationsView extends GetView<OtoConversationsController> {
  const OtoConversationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ((controller.isLoadingConversations &&
                  controller.isConversationsListEmptyFromDatabase) ||
              controller.isLoadingConversationsFromDatabase)
          ? const ConversationListSkeleton()
          : LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Material(
                  color: context.chatListBackground,
                  child: Obx(
                    () => SmartRefresher(
                      controller: controller.refreshController,
                      header: const WaterDropMaterialHeader(),
                      onRefresh: () async {
                        await controller.getAllConversations();
                        controller.refreshController.refreshCompleted();
                      },
                      child: controller.conversations.isEmpty
                          ? const Center(child: Text("No Conversation Yet...!"))
                          : ListView.builder(
                              itemCount: controller.isSearchEnabled.value
                                  ? controller.filteredConversations.length
                                  : controller.conversations.length,
                              itemBuilder: (BuildContext context, int index) {
                                final ConversationEntity conversation =
                                    controller.isSearchEnabled.value
                                        ? controller.filteredConversations
                                            .elementAt(index)
                                        : controller.conversations
                                            .elementAt(index);
                                return _ConversationTile(
                                  conversation: conversation,
                                  index: index,
                                );
                              },
                            ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _ConversationTile extends GetView<OtoConversationsController> {
  final ConversationEntity conversation;
  final int index;
  const _ConversationTile({required this.conversation, required this.index});

  @override
  Widget build(BuildContext context) {
    final myId = CommonVariables.settings.read(APPLICANT_ID).toString();

    String messageString = "";
    bool isMediaMessage = false;
    String? mediaIcon;
    ConversationMessageEntity? messageEntity;

    if (conversation.message?.deletedAt != null) {
      messageString = "🚫 This message was deleted.";
    } else if (conversation.message?.type == MessageTypes.callLog) {
      messageString = controller.getCallText(
        0,
        'oto',
        conversation.message?.message ?? "",
        conversation.message?.duration,
      );
      try {
        if (conversation.message != null) {
          messageEntity = ConversationMessageModel.fromJson(
            conversation.message?.toJson() ?? {},
          );
        }
      } catch (_) {}
    } else {
      if (conversation.message?.modelId.toString() == myId) {
        messageString += "You: ";
      }

      final msgType = conversation.message?.type;

      if (msgType == MessageTypes.gif) {
        isMediaMessage = true;
        mediaIcon = null;
        messageString += "GIF";
      } else if (msgType == MessageTypes.image) {
        isMediaMessage = true;
        messageString += "Photo 📎";

        final hasAtt = conversation.message?.attachments?.isNotEmpty ?? false;
        if (hasAtt) {
          final att = conversation.message!.attachments!.first;
          final fileName = att.fileName;
          if (fileName != null && fileName.isNotEmpty) {
            final ext = MessageFileHelper.getFileExtension(fileName);
            final ftype = MessageFileHelper.getFileType(ext);
            mediaIcon = MessageFileHelper.getFileIcon(ftype);
          }
        }
      } else if (msgType == MessageTypes.audio ||
          msgType == MessageTypes.recorded) {
        isMediaMessage = true;

        final hasAtt = conversation.message?.attachments?.isNotEmpty ?? false;
        if (hasAtt) {
          final att = conversation.message!.attachments!.first;
          final fileName = att.fileName;
          if (fileName != null && fileName.isNotEmpty) {
            final ext = MessageFileHelper.getFileExtension(fileName);
            final ftype = MessageFileHelper.getFileType(ext);
            mediaIcon = MessageFileHelper.getFileIcon(ftype);
          }
        }

        if (conversation.message?.duration != null) {
          messageString +=
              " ${controller.formatAudioMessageDuration(conversation.message!.duration ?? 0)} ";
        }
      } else if ((conversation.message?.attachments?.isNotEmpty ?? false)) {
        isMediaMessage = true;
        messageString += "media 📎";
      } else if ((conversation.message?.message != null) &&
          (conversation.message?.message != "null")) {
        messageString += (conversation.message?.message ?? "");
      }
    }

    ConversationsController? conversationsController;
    try {
      if (Get.isRegistered<ConversationsController>()) {
        conversationsController = Get.find<ConversationsController>();
      }
    } catch (_) {}

    final bool hasUnread =
        (conversation.unreadCount != null) && (conversation.unreadCount! > 0);

    return InkWell(
      onTap: () async {
        await Get.toNamed(Routes.CHAT_DETAIL, arguments: {
          'type': "oto",
          'userId': conversation.user?.id,
          'userPhone': conversation.user?.phone ?? "",
          'userImage': conversation.user?.image ?? "",
          'userName': conversation.user?.name ?? "",
          'modelType': conversation.user?.modelType ?? "",
          'chatable': conversation.chatAble,
          'conversation_id': conversation.id,
          'messages': null,
        });

        for (int i = 0; i < controller.conversations.length; i++) {
          if (controller.conversations[i].id == conversation.id) {
            controller.conversations[i].unreadCount = 0;
            controller.conversations.refresh();
            break;
          }
        }

        for (int i = 0; i < controller.filteredConversations.length; i++) {
          if (controller.filteredConversations[i].id == conversation.id) {
            controller.filteredConversations[i].unreadCount = 0;
            controller.filteredConversations.refresh();
            break;
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            // avatar with unread ring + online dot
            InkWell(
              onTap: () {
                if ((conversation.user?.image ?? "").isNotEmpty) {
                  showImageDialog(context, conversation.user?.image ?? "");
                }
              },
              customBorder: const CircleBorder(),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: hasUnread ? AppColors.primary : Colors.transparent,
                    width: 2.r,
                  ),
                ),
                child: Stack(
                  children: [
                    ProfileImage.network(
                      url: conversation.user?.image,
                      height: 52,
                      width: 52,
                      fit: BoxFit.cover,
                    ),
                    Obx(
                      () => Positioned(
                        bottom: 1,
                        right: 1,
                        child: Container(
                          width: 12.r,
                          height: 12.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (conversationsController?.isUserOnline(
                                      conversation.user?.id,
                                      conversation.user?.modelType,
                                    ) ??
                                    false)
                                ? AppColorsLight.onlineColor
                                : context.offlineDotColor,
                            border: Border.all(
                              color: context.chatListBackground,
                              width: 2.r,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // two-line text column
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // top: name + timestamp
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: AppText(
                          text: conversation.user?.name ?? "",
                          color: context.strongTextColor,
                          size: 15,
                          weight: FontWeight.w600,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      AppText(
                        text: conversation.dateTimeInHumans ?? "",
                        // unread is carried by the badge, not the timestamp
                        color: context.chatPreviewColor,
                        size: 12,
                        maxLines: 1,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  // bottom: preview + unread badge
                  Row(
                    children: [
                      if (conversation.message?.type == MessageTypes.callLog &&
                          messageEntity != null) ...[
                        CallLogConversationsIcon(
                          message: messageEntity,
                          width: 10,
                          height: 10,
                        ),
                        SizedBox(width: 4.w),
                      ],
                      Expanded(
                        child: isMediaMessage && mediaIcon != null
                            ? Row(
                                children: [
                                  AppText(
                                    text: messageString,
                                    color: context.chatPreviewColor,
                                    size: 13,
                                    maxLines: 1,
                                  ),
                                  SizedBox(width: 4.w),
                                  conversation.message?.type ==
                                          MessageTypes.recorded
                                      ? Icon(
                                          Icons.mic,
                                          size: 16.r,
                                          color: context.chatPreviewColor,
                                        )
                                      : Image.asset(
                                          mediaIcon,
                                          width: 16.r,
                                          height: 16.r,
                                        ),
                                ],
                              )
                            : AppText(
                                text: messageString,
                                color: context.chatPreviewColor,
                                size: 13,
                                maxLines: 1,
                              ),
                      ),
                      if (hasUnread) ...[
                        SizedBox(width: 8.w),
                        UnreadBadge(count: conversation.unreadCount!),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
