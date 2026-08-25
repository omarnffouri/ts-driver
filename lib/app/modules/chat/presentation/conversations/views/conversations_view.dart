import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/widgets/app_red_header.dart';
import 'package:ts_driver/app/core/widgets/glass_segmented_tabs.dart';
import 'package:ts_driver/app/modules/chat/presentation/group_conversations/views/group_conversations_view.dart';
import 'package:ts_driver/app/modules/chat/presentation/oto_conversations/views/oto_conversations_view.dart';
import 'package:ts_driver/app/modules/chat/presentation/conversations/views/components/chat_tab_bar_item.dart';
import '../controllers/conversations_controller.dart';

class ConversationsView extends GetView<ConversationsController> {
  const ConversationsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
            color: context.chatListBackground,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              const _Header(),
              const SizedBox(height: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24.r),
                    bottomRight: Radius.circular(24.r),
                  ),
                  child: Obx(
                    () => IndexedStack(
                      index:
                          controller.currentTab.value == ConversationTabs.group
                              ? 0
                              : 1,
                      children: const [
                        GroupConversationsView(),
                        OtoConversationsView(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends GetView<ConversationsController> {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return AppRedHeader(
      radius: 24,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        children: [
          Obx(
            () => GlassSegmentedTabs<ConversationTabs>(
              value: controller.currentTab.value,
              segments: const {
                ConversationTabs.group: 'Group',
                ConversationTabs.chat: 'Chat',
              },
              badgeBuilder: (tab, selected) =>
                  ChatTabBarItem(tab: tab, selected: selected),
              onChanged: (tab) {
                // Defer the IndexedStack swap until the indicator pill has
                // slid across, so the content doesn't jump ahead of it.
                Future.delayed(const Duration(milliseconds: 200), () {
                  controller.changeTab(tab);
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          const _SearchField(),
        ],
      ),
    );
  }
}

class _SearchField extends GetView<ConversationsController> {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    final iconColor = Colors.white.withValues(alpha: .8);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: .20)),
      ),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller.searchTextController,
        builder: (context, value, _) => TextField(
          controller: controller.searchTextController,
          maxLines: 1,
          cursorColor: Colors.white,
          style: const TextStyle(color: Colors.white),
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: "Search by name",
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: .7)),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            icon: Icon(Icons.search, color: iconColor),
            suffixIcon: value.text.isEmpty
                ? null
                : GestureDetector(
                    onTap: controller.searchTextController.clear,
                    child: Icon(Icons.close_rounded, color: iconColor),
                  ),
          ),
        ),
      ),
    );
  }
}
