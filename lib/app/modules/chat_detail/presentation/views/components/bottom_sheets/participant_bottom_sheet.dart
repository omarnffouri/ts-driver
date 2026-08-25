import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';

void showParticipantBottomSheet(ChatDetailController controller) {
  showModalBottomSheet(
    context: Get.context!,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20.0),
      ),
    ),
    builder: (context) {
      return ParticipantBottomSheetContent(
        controller: controller,
      );
    },
  );
}

class ParticipantBottomSheetContent extends StatelessWidget {
  final ChatDetailController controller;
  const ParticipantBottomSheetContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.sheetColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            height: 50,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Members",
                    style: TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      size: 25,
                      color: AppColors.onPrimary,
                    ),
                  )
                ]),
          ),
          Obx(() => (controller
                      .conversationDetails.value?.participants?.isNotEmpty ??
                  false)
              ? Container(
                  constraints: BoxConstraints(maxHeight: Get.height * 0.80),
                  child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: controller
                          .conversationDetails.value!.participants!.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: index == 0
                              ? const EdgeInsets.only(
                                  left: 1, right: 1, top: 14)
                              : index ==
                                      (controller.conversationDetails.value!
                                              .participants!.length -
                                          1)
                                  ? const EdgeInsets.only(
                                      left: 1, right: 1, bottom: 14)
                                  : const EdgeInsets.symmetric(horizontal: 1),
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 45,
                                height: 45,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.network(
                                    controller.conversationDetails.value!
                                            .participants![index].image ??
                                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDwmG52pVI5JZfn04j9gdtsd8pAGbqjjLswg&usqp=CAU",
                                    width: 45,
                                    height: 45,
                                    cacheWidth: 135,
                                    errorBuilder: (context, error,
                                            stackTrace) =>
                                        Image.network(
                                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDwmG52pVI5JZfn04j9gdtsd8pAGbqjjLswg&usqp=CAU"),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.conversationDetails.value!
                                              .participants![index].name ??
                                          "",
                                      style: TextStyle(
                                          color: context.primaryTextColor,
                                          fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      (controller
                                                      .conversationDetails
                                                      .value!
                                                      .participants![index]
                                                      .modelType ??
                                                  "users") ==
                                              "users"
                                          ? "Admin"
                                          : "Driver",
                                      style: TextStyle(
                                          color: context.secondaryTextColor,
                                          fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (controller.conversationDetails.value!
                                      .participants![index].isGroupAdmin ??
                                  false)
                                const Text(
                                  "Group Admin",
                                  style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                )
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Row(
                          children: [
                            const SizedBox(
                              width: 62,
                            ),
                            Expanded(
                              child: Divider(
                                height: 0,
                                color: context.dividerColor,
                              ),
                            ),
                          ],
                        );
                      }),
                )
              : Column(
                  children: [
                    const Text(
                      "No member found.",
                      style: TextStyle(color: AppColors.primary, fontSize: 16),
                    ).paddingOnly(top: 50),
                    const SizedBox(
                      height: 50,
                    ),
                    Obx(() => controller.isLoadingChatDetails
                        ? const CircularProgressIndicator(
                            color: AppColors.primary,
                          )
                        : GestureDetector(
                            onTap: () {
                              controller.getChatDetails();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Text(
                                "Refresh",
                                style: TextStyle(color: AppColors.onPrimary),
                              ),
                            ),
                          )),
                    const SizedBox(
                      height: 50,
                    ),
                  ],
                ))
        ],
      ),
    );
  }
}
