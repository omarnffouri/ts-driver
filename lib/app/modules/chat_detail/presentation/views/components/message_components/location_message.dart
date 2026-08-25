import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/message_receipt_ticks.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/message_time_view.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/widgets/main_chat_container.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationMessage extends GetView<ChatDetailController> {
  final ConversationMessageEntity message;

  const LocationMessage({
    super.key,
    required this.message,
  });

  bool get isSender => message.modelId.toString() == controller.myId;

  @override
  Widget build(BuildContext context) {
    final LocationModel? coords = message.location;
    final mapUrl = controller.getStaticMapUrl(coords);

    return GestureDetector(
      onTap: () async {
        if (coords != null) {
          final url =
              "https://www.google.com/maps/search/?api=1&query=${coords.lat},${coords.lng}";
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url),
                mode: LaunchMode.externalApplication);
          }
        } else {
          CommonWidgets.showSnackBar(
            title: 'Error',
            message: 'No location available',
          );
        }
      },
      child: MainChatContainer(
        padding: const EdgeInsets.all(4),
        isSender: isSender,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mapUrl.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  mapUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 150,
                  cacheHeight: 450,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 150,
                      color: AppColors.primary,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.onPrimary),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: AppColors.primary,
                      child: const Center(
                        child: FaIcon(
                          FontAwesomeIcons.mapPin,
                          color: AppColors.onPrimary,
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              SizedBox(
                height: 150,
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.mapPin,
                    color: isSender ? AppColors.onPrimary : AppColors.primary,
                    size: 32,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.mapPin,
                    color: isSender ? AppColors.onPrimary : AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Shared Location",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isSender
                          ? AppColors.onPrimary
                          : context.receivedBubbleTextColor,
                    ),
                  ),
                  const Spacer(),
                  MessageTimeView(message: message),
                  const SizedBox(width: 2),
                  if (message.modelId.toString() == controller.myId)
                    MessageReceiptTicks(isSender: true, message: message)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
