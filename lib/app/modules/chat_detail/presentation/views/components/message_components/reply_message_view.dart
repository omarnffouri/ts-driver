// import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/values/constants.dart';
import 'package:ts_driver/app/modules/chat_detail/data/enums/message_types.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/call_log_icon.dart';

class ReplyMessageView extends GetView<ChatDetailController> {
  final ConversationMessageEntity message;
  final bool isSenderView;

  const ReplyMessageView(
      {super.key, required this.message, required this.isSenderView});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
          maxWidth: Get.width * 0.80, minHeight: 50, maxHeight: 66),
      decoration: BoxDecoration(
        color: isSenderView
            ? AppColors.onPrimary.withValues(alpha: 0.18)
            : context.dividerColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
          topLeft: Radius.circular(5),
          bottomLeft: Radius.circular(5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: double.infinity,
            decoration: BoxDecoration(
              color: isSenderView
                  ? AppColors.onPrimary
                  : context.receivedBubbleTextColor.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.modelId.toString() == controller.myId
                      ? "You"
                      : controller.type == "group"
                          ? controller.userName
                          : message.model?.name ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: isSenderView
                          ? AppColors.onPrimary.withValues(alpha: 0.7)
                          : context.receivedBubbleTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w900),
                ).marginOnly(bottom: 5),
                Row(
                  children: [
                    if (message.type == MessageTypes.callLog)
                      CallLogIcon(message: message, width: 20, height: 20),

                    // text view
                    Expanded(
                        child: Text.rich(
                      TextSpan(
                          children: _replaceUserMentions(
                        message.message != "null" && message.message != null
                            ? message.type == MessageTypes.callLog
                                ? controller.getCallText(
                                    0, message.message!, message.duration)
                                : message.message!
                            : "",
                        TextStyle(
                          color: isSenderView
                              ? AppColors.onPrimary.withValues(alpha: 0.7)
                              : context.receivedBubbleTextColor,
                          fontSize: 12,
                        ),
                      ).children),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    )

                        // Text(
                        //   message.message != "null" && message.message != null
                        //       ? message.message!
                        //       : "",
                        //   maxLines: 2,
                        //   overflow: TextOverflow.ellipsis,
                        //   style: TextStyle(
                        //       color: isSenderView ? Colors.grey : Colors.white70,
                        //       fontSize: 12,
                        //       fontWeight: FontWeight.w900),
                        // ),
                        ),
                  ],
                ),
              ],
            ).marginAll(5),
          ),
          if (message.attachments?.isNotEmpty ?? false)
            (message.type == MessageTypes.image)
                ? message.sendedNow
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          message.attachments![0].file!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          cacheWidth: 150,
                        ),
                      ).marginOnly(right: 5)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image(
                          image: ResizeImage(
                            CachedNetworkImageProvider(
                              message.attachments?[0].url ?? "",
                            ),
                            width: 150,
                          ),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.image,
                            size: 50,
                          ),
                        ),
                      ).marginOnly(right: 5)
                : (message.type == MessageTypes.audio ||
                        message.type == MessageTypes.recorded)
                    ? Row(
                        children: [
                          Icon(Icons.mic,
                              size: 25,
                              color: isSenderView
                                  ? AppColors.onPrimary.withValues(alpha: 0.7)
                                  : context.receivedBubbleTextColor),
                          Text(
                            formatTime(message.duration ?? 0),
                            style: TextStyle(
                                fontSize: 12,
                                color: isSenderView
                                    ? AppColors.onPrimary.withValues(alpha: 0.7)
                                    : context.receivedBubbleTextColor,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ).marginOnly(right: 5)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            controller.fileExtensionHelper.getFileIcon(
                              controller.fileExtensionHelper.getFileType(
                                message.attachments![0].url ?? "",
                              ),
                            ),
                            width: 25,
                            height: 25,
                          ),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 70),
                            child: Text(
                              controller.fileExtensionHelper.getFileName(
                                message.attachments?[0].url ??
                                    "/some_file.jhghj",
                              ),
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isSenderView
                                      ? AppColors.onPrimary
                                          .withValues(alpha: 0.7)
                                      : context.receivedBubbleTextColor,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          )
                        ],
                      ).marginOnly(right: 5),
        ],
      ),
    );
  }

  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '$hours:${_twoDigits(minutes)}:${_twoDigits(remainingSeconds)}';
    } else {
      return '${_twoDigits(minutes)}:${_twoDigits(remainingSeconds)}';
    }
  }

  String _twoDigits(int n) {
    if (n >= 10) {
      return '$n';
    } else {
      return '0$n';
    }
  }

  TextSpan _replaceUserMentions(String text, TextStyle? effectiveTextStyle) {
    RegExp userIdRegex = RegExp(r'\[~(\d+)\]');
    Iterable<Match> matches = userIdRegex.allMatches(text);

    final myId = CommonVariables.settings.read(APPLICANT_ID).toString();

    List<InlineSpan> spans = [];

    int lastIndex = 0;
    for (Match match in matches) {
      // Add text before the mention and also call a bold text spans function
      spans.addAll(_makeBoldTextSpansBetweenStars(
                  text.substring(lastIndex, match.start), effectiveTextStyle)
              .children ??
          []);

      int userId = int.parse(match.group(1)!); // Extract user id from the match
      ConversationMentionEntity? user;

      try {
        user = message.mentions
            ?.firstWhere((user) => user.participantId == userId);
      } catch (_) {}

      // Replace [~userId] with the user name
      if (user != null) {
        if (user.id?.toString() != myId) {
          spans.add(TextSpan(
            text: controller.userName,
            style: effectiveTextStyle?.copyWith(color: AppColors.info),
          ));
        } else {
          spans.add(TextSpan(
            text: user.user?.name ?? "Unknown",
            style: effectiveTextStyle?.copyWith(color: AppColors.info),
          ));
        }
      }

      lastIndex = match.end;
    }

    // Add the remaining text after the last mention and also call a bold text spans function
    if (lastIndex < text.length) {
      String remainingText = text.substring(lastIndex);
      spans.addAll(
          _makeBoldTextSpansBetweenStars(remainingText, effectiveTextStyle)
                  .children ??
              []);
    }

    return TextSpan(children: spans);
  }

  TextSpan _makeBoldTextSpansBetweenStars(
      String text, TextStyle? effectiveTextStyle) {
    List<InlineSpan> spans = [];
    RegExp boldRegex = RegExp(r'\*(.*?)\*');

    Iterable<Match> boldMatches = boldRegex.allMatches(text);

    int lastIndex = 0;
    for (Match boldMatch in boldMatches) {
      // Add text before the bold section
      spans.add(TextSpan(
        text: text.substring(lastIndex, boldMatch.start),
        style: effectiveTextStyle,
      ));

      // Add bold text
      spans.add(TextSpan(
        text: boldMatch.group(1),
        style: effectiveTextStyle?.copyWith(fontWeight: FontWeight.bold),
      ));

      lastIndex = boldMatch.end;
    }

    // Add the remaining text after the last bold section
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: effectiveTextStyle,
      ));
    }

    return TextSpan(children: spans);
  }
}
