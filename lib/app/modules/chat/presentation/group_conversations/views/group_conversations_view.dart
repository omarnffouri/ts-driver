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
import 'package:ts_driver/app/modules/chat/presentation/conversations/views/components/call_log_conversations_icon.dart';
import 'package:ts_driver/app/modules/chat/presentation/conversations/views/components/conversation_list_skeleton.dart';
import 'package:ts_driver/app/modules/chat/presentation/conversations/views/components/unread_badge.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/group_conversation_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/data/enums/message_types.dart';
import 'package:ts_driver/app/modules/chat_detail/data/models/conversation_details_model.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';
import 'package:ts_driver/app/routes/app_pages.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/profile_image.dart';

import '../controllers/group_conversations_controller.dart';

class GroupConversationsView extends GetView<GroupConversationsController> {
  const GroupConversationsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ((controller.isLoadingGroupConversations &&
                  controller.isGroupConversationsListEmptyFromDatabase) ||
              controller.isLoadingGroupConversationsFromDatabase)
          ? const ConversationListSkeleton()
          : LayoutBuilder(builder: (
              BuildContext context,
              BoxConstraints constraints,
            ) {
              return Material(
                color: context.chatListBackground,
                child: Obx(
                  () => SmartRefresher(
                    controller: controller.groupConversationsRefreshController,
                    header: const WaterDropMaterialHeader(),
                    onRefresh: () async {
                      await controller.getAllGroupConversations();
                      controller.groupConversationsRefreshController
                          .refreshCompleted();
                    },
                    child: controller.groupConversations.isEmpty
                        ? const Center(child: Text("No Group Yet...!"))
                        : ListView.builder(
                            itemCount: controller.isSearchEnabled.value
                                ? controller.filteredGroupConversations.length
                                : controller.groupConversations.length,
                            itemBuilder: (BuildContext context, int index) {
                              final GroupConversationEntity groupConversation =
                                  controller.isSearchEnabled.value
                                      ? controller.filteredGroupConversations
                                          .elementAt(index)
                                      : controller.groupConversations
                                          .elementAt(index);
                              return _GroupConverstionTile(
                                groupConversation: groupConversation,
                                index: index,
                              );
                            },
                          ),
                  ),
                ),
              );
            }),
    );
  }
}

class _GroupConverstionTile extends GetView<GroupConversationsController> {
  final int index;
  final GroupConversationEntity groupConversation;
  const _GroupConverstionTile({
    required this.groupConversation,
    required this.index,
  });

  static final RegExp _mentionRegex = RegExp(r'\[~(\d+)\]');

  @override
  Widget build(BuildContext context) {
    final myId = CommonVariables.settings.read(APPLICANT_ID).toString();

    // building message string
    String messageString = "";
    bool isMediaMessage = false;
    String? mediaIcon;

    ConversationMessageEntity? messageEntity;
    if (groupConversation.message?.deletedAt != null) {
      messageString = "🚫 This message was deleted.";
    } else if (groupConversation.message?.type == MessageTypes.callLog) {
      messageString = controller.getCallText(
          0,
          'oto',
          groupConversation.message?.message ?? "",
          groupConversation.message?.duration);
      try {
        if (groupConversation.message != null) {
          messageEntity = ConversationMessageModel.fromJson(
              groupConversation.message?.toJson() ?? {});
        }
      } catch (_) {}
    } else {
      // if message was sent by me then add a you at the start of the string
      if (groupConversation.message?.modelId.toString() == myId) {
        messageString += "You: ";
      }

      // if message contains a media then show that last message is media
      if (groupConversation.message?.attachments?.isNotEmpty ?? false) {
        final media = groupConversation.message!.attachments![0];
        if (media.fileName != null) {
          isMediaMessage = true;
          final fileType = MessageFileHelper.getFileType(
              MessageFileHelper.getFileExtension(media.fileName!));
          mediaIcon = MessageFileHelper.getFileIcon(fileType);

          if ((fileType != MessageFileType.none) &&
              (groupConversation.message!.duration != null) &&
              (groupConversation.message!.type == MessageTypes.audio ||
                  groupConversation.message!.type == MessageTypes.recorded)) {
            messageString +=
                " ${controller.formatAudioMessageDuration(groupConversation.message!.duration ?? 0)} ";
          }
        } else {
          messageString += "media 📎";
        }
      }
      // else if last message is not null concat the message string
      else if ((groupConversation.message?.message != null) &&
          (groupConversation.message?.message != "null")) {
        messageString += (groupConversation.message?.message ?? "");
      }
    }

    final bool hasUnread = (groupConversation.unreadCount != null) &&
        (groupConversation.unreadCount! > 0);
    final bool hasMention = groupConversation.mentioned?.isNotEmpty ?? false;
    final previewStyle =
        TextStyle(color: context.chatPreviewColor, fontSize: 13.sp);

    return InkWell(
      onTap: () async {
        await Get.toNamed(Routes.CHAT_DETAIL, arguments: {
          'type': "group",
          'userPhone': (groupConversation.participants
                      ?.map((e) =>
                          e.id.toString() == myId.toString() ? "You" : e.name)
                      .toString() ??
                  "")
              .replaceAll("(", "")
              .replaceAll(")", ""),
          'userImage': "",
          'userName': groupConversation.name ?? "",
          'modelType': "",
          'conversation_id': groupConversation.id,
          'chatable': groupConversation.chatAble,
          'i_am_participant':
              groupConversation.participants?.firstWhereOrNull((element) {
                    return element.id.toString() == myId;
                  }) !=
                  null,
          'messages': null
        });

        for (int i = 0; i < controller.groupConversations.length; i++) {
          if (controller.groupConversations[i].id == groupConversation.id) {
            controller.groupConversations[i].unreadCount = 0;
            controller.groupConversations.refresh();
            break;
          }
        }

        for (int i = 0; i < controller.filteredGroupConversations.length; i++) {
          if (controller.filteredGroupConversations[i].id ==
              groupConversation.id) {
            controller.filteredGroupConversations[i].unreadCount = 0;
            controller.filteredGroupConversations.refresh();
            break;
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            // avatar with unread ring
            InkWell(
              onTap: () {
                if ((groupConversation.groupSettings?.logo ?? "").isNotEmpty) {
                  showImageDialog(
                    context,
                    groupConversation.groupSettings!.logo!,
                  );
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
                child: ProfileImage.network(
                  url: groupConversation.groupSettings?.logo,
                  width: 52,
                  height: 52,
                  showLetterOnError: true,
                  letter: ((groupConversation.name ?? "").isNotEmpty
                      ? groupConversation.name![0].capitalize ?? "G"
                      : "G"),
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
                          text: groupConversation.name ?? "",
                          color: context.strongTextColor,
                          size: 15,
                          weight: FontWeight.w600,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      AppText(
                        text: groupConversation.dateTimeInHumans ?? "",
                        // unread is carried by the badge, not the timestamp
                        color: context.chatPreviewColor,
                        size: 12,
                        maxLines: 1,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  // bottom: preview + mention + unread badge
                  Row(
                    children: [
                      if (groupConversation.message?.type ==
                              MessageTypes.callLog &&
                          messageEntity != null) ...[
                        CallLogConversationsIcon(
                            message: messageEntity, width: 10, height: 10),
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
                                  groupConversation.message?.type ==
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
                            : Text.rich(
                                _replaceUserMentions(
                                    messageString, previewStyle),
                                style: previewStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                      if (hasMention) ...[
                        SizedBox(width: 8.w),
                        Text(
                          "@",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      if (hasUnread) ...[
                        SizedBox(width: 6.w),
                        UnreadBadge(count: groupConversation.unreadCount!),
                      ],
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextSpan _replaceUserMentions(String text, TextStyle? effectiveTextStyle) {
    Iterable<Match> matches = _mentionRegex.allMatches(text);

    final myId = CommonVariables.settings.read(APPLICANT_ID).toString();

    List<InlineSpan> spans = [];

    int lastIndex = 0;
    for (Match match in matches) {
      // Add text before the mention and also call a bold text spans function
      spans.add(
        TextSpan(
          text: text.substring(lastIndex, match.start),
          style: effectiveTextStyle,
        ),
      );

      int userId = int.parse(match.group(1)!); // Extract user id from the match
      ParticipantEntity? user;

      try {
        user = groupConversation.participants
            ?.firstWhere((user) => user.pid == userId);
      } catch (_) {}

      // Replace [~userId] with the user name
      if (user != null) {
        if (user.id?.toString() != myId) {
          spans.add(TextSpan(
            text: groupConversation.groupName ?? "Unknown",
            style: effectiveTextStyle?.copyWith(
                color: Get.isDarkMode
                    ? Colors.blue
                    : groupConversation.message?.modelId?.toString() == myId
                        ? AppColorsLight.mainColor
                        : Colors.blue), // Change color as needed
          ));
        } else {
          spans.add(TextSpan(
            text: user.name ?? "Unknown",
            style: effectiveTextStyle?.copyWith(
                color: Get.isDarkMode
                    ? Colors.blue
                    : groupConversation.message?.modelId?.toString() == myId
                        ? AppColorsLight.mainColor
                        : Colors.blue), // Change color as needed
          ));
        }
      }

      lastIndex = match.end;
    }

    // Add the remaining text after the last mention and also call a bold text spans function
    if (lastIndex < text.length) {
      spans.add(
          TextSpan(text: text.substring(lastIndex), style: effectiveTextStyle));
    }

    return TextSpan(children: spans);
  }
}
