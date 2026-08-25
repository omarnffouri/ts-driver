import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';

class MapMessage extends GetView<ChatDetailController> {
  final ConversationMessageEntity message;

  const MapMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: Get.width * 0.75),
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(5),
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
      child: InkWell(
        onTap: () {
          // Get.to(
          //   ImagePreview(
          //     title: "",
          //     image: message.url,
          //   ),
          // );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 150,
            height: 150,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(13.256222, 34.9655),
                zoom: 12.0,
              ),
              markers: {
                const Marker(
                  markerId: MarkerId("some name"),
                  position: LatLng(13.256222, 34.9655),
                ),
              },
              zoomControlsEnabled: false,
              zoomGesturesEnabled: false,
              scrollGesturesEnabled: false,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: false,
            ),
          ),
        ),
      ),
    );
  }
}
