import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/utils/swiper.dart';
import 'package:ts_driver/app/modules/chat_detail/data/enums/message_types.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/buzz_components/conversation_buzz_view.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/call_log_view.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/deleted_message.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/document_message.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/gif_message.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/image_message.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/location_message.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/text_message_receiver.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/text_message_sender.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/video_message.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/voice_message.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/reaction_components/widgets/flat_reactions_view.dart';

class MessageMainView extends GetView<ChatDetailController> {
  final ConversationMessageEntity message;
  final int index;

  const MessageMainView({
    super.key,
    required this.message,
    required this.index,
  });

  bool get isSender => message.modelId.toString() == controller.myId;

  @override
  Widget build(BuildContext context) {
    if (!isSender) {
      controller.markMessageAsRead(message);
    }

    return GestureDetector(
      onLongPress: () {
        if (message.type != MessageTypes.callLog) {
          controller.selectMessage(message);
        }
      },
      onTap: () {
        if (message.type != MessageTypes.callLog &&
            controller.isMessageSelectionEnabled) {
          controller.selectMessage(message);
        }
      },
      child: Swiper(
        iconColor: AppColors.primary,
        onRightSwipe: message.deletedAt == null
            ? (_) => controller.selectedMessageForReply.value =
                controller.messages[index]
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isSender) ...[
              _buildUserAvatar(context),
              const SizedBox(width: 5),
            ] else
              const Spacer(),

            //
            // message view stack (message + reactions)
            Builder(builder: (context) {
              final RenderBox? box = context.findRenderObject() as RenderBox?;
              final widgetWidth = box?.size.width;

              return Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      bottom: (message.reactions?.isNotEmpty ?? false) ? 15 : 0,
                    ),
                    child: _buildMessageContent(message),
                  ),
                  Positioned(
                    bottom: 0,
                    right: isSender ? 0 : null,
                    child: GestureDetector(
                      onTap: () =>
                          controller.showMessageReactionBottomSheet(message),
                      child: FlatReactionsView(
                        size: 15,
                        maxWidth:
                            ((widgetWidth ?? 0) < 50) ? 50 : widgetWidth ?? 50,
                        direction:
                            isSender ? TextDirection.rtl : TextDirection.ltr,
                        reactions: message.reactions
                                ?.map((e) => e.reaction!)
                                .toList() ??
                            [],
                        backgroundColor: context.reactionChipColor,
                        borderColor: context.backgroundColor,
                        emojiCounterTextStyle:
                            Theme.of(context).textTheme.bodySmall!,
                      ),
                    ),
                  ),
                ],
              );
            }),

            if (isSender) ...[
              const SizedBox(width: 5),
              _buildUserAvatar(context),
            ] else
              const Spacer(),

            if (!isSender)
              Obx(() => Visibility(
                    visible: (controller.receivedBuzz &&
                        ((message.id == controller.buzzOnMessageId.value) &&
                            (message.id != null))),
                    child: const ConversationBuzzView(
                      size: 40,
                      inMessageView: true,
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    const fallbackImg =
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDwmG52pVI5JZfn04j9gdtsd8pAGbqjjLswg&usqp=CAU";

    return controller.type == "group" && !isSender
        ? Container(
            margin: const EdgeInsets.only(top: 5),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: context.dividerColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: Text(
                controller.userName[0].toUpperCase(),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.primaryTextColor),
              ),
            ),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image(
              image: CachedNetworkImageProvider(
                message.model?.image ?? fallbackImg,
              ),
              width: 20,
              height: 20,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.network(
                fallbackImg,
                width: 20,
                height: 20,
              ),
            ),
          );
  }

  Widget _buildMessageContent(ConversationMessageEntity message) {
    if (message.deletedAt != null) return DeletedMessage(message: message);

    if (message.type == MessageTypes.gif) {
      return GifMessage(message: message);
    }

    if (message.attachments?.isNotEmpty ?? false) {
      switch (message.type) {
        case MessageTypes.image:
          return ImageMessage(message: message);
        case MessageTypes.audio:
        case MessageTypes.recorded:
          return VoiceMessage(
              key: ValueKey('voice_${message.id ?? message.tempId ?? index}'),
              message: message);
        default:
          if (controller.fileExtensionHelper
              .isVideoFile(message.attachments?[0].mimeType ?? "")) {
            return VideoMessage(message: message);
          }
          return DocumentMessage(message: message);
      }
    }

    if (message.type == MessageTypes.callLog) {
      return CallLogMessage(message: message);
    }

    if (message.type == MessageTypes.location) {
      return LocationMessage(
        message: message,
      );
    }

    return isSender
        ? TextMessageSender(message: message)
        : TextMessageReceiver(message: message);
  }
}
