import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/modules/forward_message/controllers/forward_message_controller.dart';

class ForwardMessageTabsHead extends GetView<ForwardMessageController> {
  const ForwardMessageTabsHead({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the current theme using the MediaQuery or Theme widget
    ThemeData theme = Theme.of(context);

    // Retrieve specific theme colors
    Color primaryColor = theme.primaryColor;
    // Color primaryColorDark = theme.primaryColorDark;
    // Color primaryColorLight = theme.primaryColorLight;
    // Color scaffoldBackgroundColor = theme.scaffoldBackgroundColor;
    // Color cardColor = theme.cardColor;

    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    controller.currentTab(ForwardMessageTabs.chat);
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          controller.currentTab.value == ForwardMessageTabs.chat
                              ? Get.isDarkMode
                                  ? AppColorsDark.conversationsSelectedTabColor
                                  : AppColorsLight.conversationsSelectedTabColor
                              : primaryColor,
                      borderRadius:
                          controller.currentTab.value == ForwardMessageTabs.chat
                              ? const BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                )
                              : const BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Chats",
                            style: TextStyle(
                              fontSize: 12,
                              color: controller.currentTab.value ==
                                      ForwardMessageTabs.chat
                                  ? kMainColor
                                  : kWhiteColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Obx(
                            () => Visibility(
                              visible:
                                  controller.selectedConversations.isNotEmpty,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                margin: const EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    shape: BoxShape.circle),
                                child: Text(
                                  controller.selectedConversations.length
                                      .toString(),
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    controller.currentTab(ForwardMessageTabs.group);
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: controller.currentTab.value ==
                              ForwardMessageTabs.group
                          ? Get.isDarkMode
                              ? AppColorsDark.conversationsSelectedTabColor
                              : AppColorsLight.conversationsSelectedTabColor
                          : primaryColor,
                      borderRadius: controller.currentTab.value ==
                              ForwardMessageTabs.group
                          ? const BorderRadius.only(
                              bottomRight: Radius.circular(15),
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            )
                          : const BorderRadius.only(
                              bottomRight: Radius.circular(15),
                            ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Groups",
                            style: TextStyle(
                              fontSize: 12,
                              color: controller.currentTab.value ==
                                      ForwardMessageTabs.group
                                  ? kMainColor
                                  : kWhiteColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Obx(
                            () => Visibility(
                              visible: controller
                                  .selectedGroupConversations.isNotEmpty,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                margin: const EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    shape: BoxShape.circle),
                                child: Text(
                                  controller.selectedGroupConversations.length
                                      .toString(),
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
