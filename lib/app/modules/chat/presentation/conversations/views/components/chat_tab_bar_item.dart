import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/core/widgets/glass_segmented_tabs.dart';
import 'package:ts_driver/app/modules/chat/presentation/conversations/controllers/conversations_controller.dart';

/// Unread-count badge for a conversation tab inside [GlassSegmentedTabs].
/// The label itself is drawn by the tab control; this only renders the count.
class ChatTabBarItem extends GetView<ConversationsController> {
  final ConversationTabs tab;
  final bool selected;
  const ChatTabBarItem({super.key, required this.tab, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = tab == ConversationTabs.group
          ? controller.groupUnreadCounts
          : controller.otoUnreadCounts;
      if (count == 0) return const SizedBox.shrink();
      return SegmentedTabBadge(
        label: count > 99 ? '99+' : '$count',
        selected: selected,
      );
    });
  }
}
