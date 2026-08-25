// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/group_conversation_entity.dart';
import 'package:ts_driver/app/modules/forward_message/controllers/forward_message_controller.dart';

class ForwardMessageGroupsTabView extends GetView<ForwardMessageController> {
  const ForwardMessageGroupsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        return Obx(
          () => controller.groupConversations.isEmpty
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("No Group Conversation Yet...!"),
                  ],
                ).paddingOnly(top: 150)
              : ListView.separated(
                  itemCount: controller.isSearchEnabled.value
                      ? controller.filteredGroupConversations.length
                      : controller.groupConversations.length,
                  itemBuilder: (BuildContext context, int index) {
                    final GroupConversationEntity conversation = controller
                            .isSearchEnabled.value
                        ? controller.filteredGroupConversations.elementAt(index)
                        : controller.groupConversations.elementAt(index);
                    return buildGroupConversationTile(
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
                ),
        );
      },
    );
  }

  Widget buildGroupConversationTile(
      int index, GroupConversationEntity groupConversation) {
    return InkWell(
      onTap: () async {
        controller.onGroupConversationTap(groupConversation.id);
      },
      child: Container(
        margin: index == 0
            ? const EdgeInsets.only(left: 1, right: 1, top: 14)
            : index == (controller.groupConversations.length - 1)
                ? const EdgeInsets.only(left: 1, right: 1, bottom: 14)
                : const EdgeInsets.symmetric(horizontal: 1),
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(100)),
              child:
                  const Center(child: Icon(Icons.group, color: Colors.white)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                groupConversation.name ?? "",
                style: const TextStyle(color: Colors.black, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            //
            Obx(
              () => Visibility(
                visible: controller.selectedGroupConversations
                    .contains(groupConversation.id),
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
