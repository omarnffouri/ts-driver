import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/modules/chat_detail/data/enums/message_types.dart';
import 'package:ts_driver/app/modules/forward_message/views/tabs/forward_message_chats_tab.dart';
import 'package:ts_driver/app/modules/forward_message/views/tabs/forward_message_groups_tab.dart';

import '../controllers/forward_message_controller.dart';

class ForwardMessageView extends GetView<ForwardMessageController> {
  const ForwardMessageView({super.key});
  @override
  Widget build(BuildContext context) {
    // getting theme data
    // final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: theme.primaryColor,
        toolbarHeight: 55.h,
        elevation: 0,
        // iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Forward Message',
        ),
        bottom: TabBar(
          indicator: BoxDecoration(
            color: AppColorsLight.mainColor,
            borderRadius: BorderRadius.circular(10),
          ),
          dividerHeight: 0,
          padding: const EdgeInsets.only(bottom: 10),
          controller: controller.tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          unselectedLabelStyle: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
          labelStyle: const TextStyle(
            color: AppColorsLight.mainColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            _ForwardTabBarItem(tab: ForwardMessageTabs.chat),
            _ForwardTabBarItem(tab: ForwardMessageTabs.group),
          ],
        ),
        // centerTitle: true,
      ),
      body: Column(
        children: [
          //
          //
          // top header
          // const ForwardMessageTabsHead(),

          //
          //
          // search field
          Container(
            margin: const EdgeInsets.only(left: 14, right: 14, top: 14),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Get.isDarkMode
                  ? Colors.black54
                  : Colors.grey[300], // Background color
            ),
            child: TextField(
                controller: controller.searchTextController,
                maxLines: 1,
                decoration: InputDecoration(
                  // contentPadding: EdgeInsets.all(0),
                  hintText: "Search by name, phone, group name",
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedErrorBorder:
                      InputBorder.none, // Remove the default border
                  icon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      controller.clearSearch();
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.grey,
                    ),
                  ),
                ) // Optional icon
                ),
          ),

          //
          //
          // body
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: const [
                ForwardMessageChatsTabView(),
                ForwardMessageGroupsTabView(),
              ],
            ),
          ),

          //
          //
          // showing message which will be forward
          Visibility(
            visible: controller.messages.length == 1,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              padding: const EdgeInsets.all(5),
              constraints: const BoxConstraints(minHeight: 50, maxHeight: 66),
              decoration: BoxDecoration(
                color: Get.isDarkMode
                    ? Colors.grey.shade800
                    : Colors.grey.shade700,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  if (controller.messages.first.attachments?.isNotEmpty ??
                      false)
                    (controller.messages.first.type == MessageTypes.image)
                        ? controller.messages.first.sendedNow
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  controller
                                      .messages.first.attachments![0].file!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ).marginOnly(right: 5)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image(
                                  image: CachedNetworkImageProvider(
                                    controller.messages.first.attachments?[0]
                                            .url ??
                                        "",
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
                        : (controller.messages.first.type ==
                                    MessageTypes.audio ||
                                controller.messages.first.type ==
                                    MessageTypes.recorded)
                            ? Row(
                                children: [
                                  const Icon(
                                    Icons.mic,
                                    size: 25,
                                  ),
                                  Text(
                                    controller.formatTime(
                                        controller.messages.first.duration ??
                                            0),
                                  ),
                                ],
                              ).marginOnly(right: 5)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    controller.getFileIcon(
                                      controller.getFileExtension(
                                        controller.getFileNameWithExtenshion(
                                            controller.messages.first
                                                    .attachments![0].url ??
                                                ""),
                                      ),
                                    ),
                                    width: 25,
                                    height: 25,
                                  ),
                                  Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 70),
                                    child: Text(
                                      controller.getFileNameWithExtenshion(
                                        controller.messages.first
                                                .attachments?[0].url ??
                                            "/some_file.jhghj",
                                      ),
                                      maxLines: 2,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  )
                                ],
                              ).marginOnly(right: 5),
                  Expanded(
                    child: Text(
                      controller.messages.first.message != "null" &&
                              controller.messages.first.message != null
                          ? controller.messages.first.message!
                          : "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ).marginAll(5),
                  ),
                ],
              ),
            ),
          ),

          //
          //
          // showing selected users name
          Obx(
            () => AnimatedSwitcher(
              transitionBuilder: (child, animation) {
                final offset = Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: const Offset(0.0, 0),
                ).animate(animation);

                return SlideTransition(
                  position: offset,
                  child: child,
                );
              },
              duration: const Duration(milliseconds: 150),
              child: (controller.selectedConversations.isNotEmpty ||
                      controller.selectedGroupConversations.isNotEmpty)
                  ? Row(
                      children: [
                        Expanded(
                          child: Text(
                            controller.getSelectedConversationsName(),
                          ),
                        ),
                        Obx(() => controller.isForwarding.value
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Get.isDarkMode
                                      ? Colors.white
                                      : AppColorsLight.mainColor,
                                ),
                              ).marginAll(10)
                            : InkWell(
                                onTap: () async {
                                  for (var item in controller.messages) {
                                    try {
                                      await controller.forwardMessage(item);
                                    } catch (_) {}
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Get.isDarkMode
                                          ? AppColorsDark.mainRedColor
                                          : AppColorsLight.mainColor),
                                  child: const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              )).marginOnly(left: 10)
                      ],
                    ).marginOnly(left: 14, right: 14, bottom: 30)
                  : const SizedBox(),
            ),
          )
        ],
      ),
    );
  }
}

class _ForwardTabBarItem extends GetView<ForwardMessageController> {
  final ForwardMessageTabs tab;
  const _ForwardTabBarItem({required this.tab});

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          tab.name.capitalizeFirst ?? '',
        ),
        if (tab == ForwardMessageTabs.chat) _buildOtoCount(),
        if (tab == ForwardMessageTabs.group) _buildGroupCount(),
      ],
    ).marginSymmetric(vertical: 10);
  }

  _buildOtoCount() {
    return Obx(
      () => Visibility(
        visible: controller.selectedConversations.isNotEmpty,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
            color: controller.currentTab.value == tab
                ? Colors.white
                : AppColorsLight.mainColor,
            shape: BoxShape.circle,
          ),
          child: Text(
            controller.selectedConversations.length > 99
                ? '99+'
                : controller.selectedConversations.length.toString(),
            style: TextStyle(
              color: controller.currentTab.value == tab
                  ? AppColorsLight.mainColor
                  : Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ),
    ).marginOnly(left: 8);
  }

  _buildGroupCount() {
    return Obx(
      () => Visibility(
        visible: controller.selectedGroupConversations.isNotEmpty,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
            color: controller.currentTab.value == tab
                ? Colors.white
                : AppColorsLight.mainColor,
            shape: BoxShape.circle,
          ),
          child: Text(
            controller.selectedGroupConversations.length > 99
                ? '99+'
                : controller.selectedGroupConversations.length.toString(),
            style: TextStyle(
              color: controller.currentTab.value == tab
                  ? AppColorsLight.mainColor
                  : Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ),
    ).marginOnly(left: 8);
  }
}
