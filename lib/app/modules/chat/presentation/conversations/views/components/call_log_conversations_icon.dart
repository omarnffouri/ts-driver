import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';
import 'package:ts_driver/app/modules/chat/presentation/conversations/controllers/conversations_controller.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

class CallLogConversationsIcon extends GetView<ConversationsController> {
  final ConversationMessageEntity message;
  final double width;
  final double height;

  const CallLogConversationsIcon(
      {super.key,
      required this.message,
      required this.width,
      required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: message.modelId.toString() == controller.myId
            ? Colors.grey.shade300
            : AppColorsLight.reciverCallBackgroundColor,
      ),
      // set icons on the bases of model or call placed by and received by
      child: message.modelId.toString() == controller.myId
          ? SvgPicture.asset(
              Assets.svg.callOutGoing,
              width: width,
              height: height,
              colorFilter: ColorFilter.mode(
                Get.isDarkMode
                    ? AppColorsDark.senderCallColor
                    : AppColorsLight.senderCallColor,
                BlendMode.srcIn,
              ),
            )
          : SvgPicture.asset(
              message.message == AgoraCallEvents.incommingCall
                  ? Assets.svg.callMissed
                  : message.message == AgoraCallEvents.callDeclined
                      ? Assets.svg.callDeclined
                      : message.message == AgoraCallEvents.callDeclined
                          ? Assets.svg.callIncomming
                          : message.message == AgoraCallEvents.noAnswer
                              ? Assets.svg.callNotAnswered
                              : message.message == AgoraCallEvents.callEnded
                                  ? Assets.svg.callIncomming
                                  : Assets.svg.callMissed,
              width: width,
              height: height,
              colorFilter: ColorFilter.mode(
                Get.isDarkMode
                    ? AppColorsDark.reciverCallColor
                    : AppColorsLight.reciverCallColor,
                BlendMode.srcIn,
              ),
            ),
    );
  }
}
