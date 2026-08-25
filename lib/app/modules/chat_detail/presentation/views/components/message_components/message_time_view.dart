// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';

class MessageTimeView extends GetView<ChatDetailController> {
  final ConversationMessageEntity message;

  const MessageTimeView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      DateFormat('h:mm a').format(message.createdAt ?? DateTime.now()),
      style: TextStyle(
          color: message.modelId.toString() == controller.myId
              ? AppColors.onPrimary
              : context.receivedBubbleTextColor,
          fontSize: 10),
    );
  }
}
