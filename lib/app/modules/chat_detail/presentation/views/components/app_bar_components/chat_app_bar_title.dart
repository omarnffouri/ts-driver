part of '../../chat_detail_view.dart';

class _ChatAppBarTitle extends GetView<ChatDetailController> {
  const _ChatAppBarTitle();

  @override
  Widget build(BuildContext context) {
    // getting theme data

    return Obx(() => controller.isSearchEnabled.value
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: context.dividerColor, // Background color
            ),
            child: TextField(
              controller: controller.searchController,
              maxLines: 1,
              decoration: InputDecoration(
                // contentPadding: EdgeInsets.all(0),
                hintText: "Enter text",
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedErrorBorder:
                    InputBorder.none, // Remove the default border
                icon: Icon(
                  Icons.search,
                  color: context.hintColor,
                ), // Optional icon
              ),
            ),
          )
        : GestureDetector(
            onTap: () {
              // if (controller.type == "group") {
              //   controller.showParticipantsBottomSheet();
              // }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (Get.width > 500) addHorizontalSpace(10.w),
                controller.type == "group"
                    ? Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                            color: context.dividerColor,
                            borderRadius: BorderRadius.circular(100)),
                        child: Center(
                            child: Text(
                          controller.userName[0].toUpperCase(),
                          style: TextStyle(color: context.primaryTextColor),
                        )),
                      )
                    : ProfileImage.network(
                        url: controller.userImage,
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                addHorizontalSpace(8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(
                        text: controller.userName,
                        size: 16,
                        color: context.strongTextColor,
                        weight: FontWeight.bold,
                        maxLines: 1,
                      ),
                      Row(
                        children: [
                          Obx(
                            () => Visibility(
                              visible: (!controller.isTyping) &&
                                  (controller.type != "group"),
                              child: Icon(
                                Icons.circle,
                                color: Get.put<ConversationsController>(
                                            ConversationsController())
                                        .isUserOnline(
                                            controller.receiverId.value,
                                            controller.receiverModelType)
                                    ? AppColorsLight.onlineColor
                                    : context.offlineDotColor,
                                size: 10,
                              ),
                            ),
                          ),
                          Obx(
                            () => Expanded(
                              child: Text(
                                controller.isTyping
                                    ? controller.typingMessage
                                    : controller.type == "group"
                                        ? "Group"
                                        : (Get.find<ConversationsController>()
                                                .isUserOnline(
                                                    controller.receiverId.value,
                                                    controller
                                                        .receiverModelType))
                                            ? "Online"
                                            : "Offline",
                                style: TextStyle(
                                    color: controller.isTyping
                                        ? AppColors.primary
                                        : context.secondaryTextColor,
                                    fontSize: 14.sp),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ));
  }
}
