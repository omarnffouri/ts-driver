// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/conversation_entity.dart';
import 'package:ts_driver/app/modules/forward_message/controllers/forward_message_controller.dart';
import 'package:ts_driver/app/core/widgets/profile_image.dart';

class ForwardMessageChatsTabView extends GetView<ForwardMessageController> {
  const ForwardMessageChatsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (
      BuildContext context,
      BoxConstraints constraints,
    ) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Obx(
              () => controller.conversations.isEmpty
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("No Conversation Yet...!"),
                      ],
                    ).paddingOnly(top: 150)
                  : controller.isSearchEnabled.value
                      ? _buildSearchListView()
                      : _buildNormalListView(),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSearchListView() {
    return ListView.separated(
      itemCount: controller.filteredConversations.length,
      itemBuilder: (BuildContext context, int index) {
        final ConversationEntity conversation =
            controller.filteredConversations.elementAt(index);
        return buildConversationTile(
          index,
          conversation,
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Row(
          children: [
            const SizedBox(
              width: 62,
            ),
            Expanded(
              child: Divider(
                height: 10.h,
                color: Colors.grey,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNormalListView() {
    return ListView.separated(
      itemCount: controller.conversations.length,
      itemBuilder: (BuildContext context, int index) {
        final ConversationEntity conversation =
            controller.conversations.elementAt(index);
        return buildConversationTile(
          index,
          conversation,
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Row(
          children: [
            const SizedBox(
              width: 62,
            ),
            Expanded(
              child: Divider(
                height: 10.h,
                color: Colors.grey,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildConversationTile(int index, ConversationEntity conversation) {
    return InkWell(
      onTap: () async {
        controller.onConversationTap(conversation.id);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileImage.network(
              url: conversation.user?.image,
              height: 45,
              width: 45,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                conversation.user?.name ?? "",
                style: const TextStyle(color: Colors.black, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Obx(
              () => Visibility(
                visible:
                    controller.selectedConversations.contains(conversation.id),
                child: const Icon(
                  Icons.done_rounded,
                  color: AppColorsLight.mainColor,
                ),
              ),
            ).marginOnly(left: 10, right: 5),
          ],
        ),
      ),
    );
  }
}
