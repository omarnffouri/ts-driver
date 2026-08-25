import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';
import 'package:ts_driver/app/modules/chat/presentation/conversations/controllers/conversations_controller.dart';

class MessageReactionsBottomSheet extends GetView<ChatDetailController> {
  final ConversationMessageEntity message;
  const MessageReactionsBottomSheet({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    //
    // conversations controller
    ConversationsController? conversationsController;
    if (Get.isRegistered<ConversationsController>()) {
      conversationsController = Get.find<ConversationsController>();
    }

    //
    // adding reacted by data in the reactions
    _addReactedByDetails();

    //
    // view
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        //
        //
        // top header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          height: 50,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Row(children: [
            const Text(
              "Reactions",
              style: TextStyle(
                  color: AppColors.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
            const Spacer(),
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

        //
        //
        // body
        (message.reactions?.isNotEmpty ?? false)
            ? Container(
                color: context.sheetColor,
                constraints: BoxConstraints(maxHeight: Get.height * 0.80),
                child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: message.reactions!.length,
                    itemBuilder: (context, index) {
                      final reaction = message.reactions![index];
                      return _ReactionListItemView(
                        reaction: reaction,
                        index: index,
                        conversationsController: conversationsController,
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
            : Container(
                width: double.infinity,
                color: context.sheetColor,
                child: Column(
                  children: [
                    const Text(
                      "No reaction on this message.",
                      style: TextStyle(color: AppColors.primary, fontSize: 16),
                    ).paddingOnly(top: 50),
                    const SizedBox(
                      height: 50,
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  // ignore: unused_element
  List<String> _getUniqueReactions() {
    List<String> uniqueReactions = [];

    if (message.reactions?.isEmpty ?? true) {
      return uniqueReactions;
    }

    //
    // filtering unique reactions
    for (var element in message.reactions!.map((e) => e.reaction!)) {
      if (!uniqueReactions.contains(element)) {
        uniqueReactions.add(element);
      }
    }
    return uniqueReactions;
  }

  _addReactedByDetails() {
    //
    // if reactions list is empty then return
    if (message.reactions?.isEmpty ?? true) {
      return;
    }

    //
    // if participants not exists then return
    if (controller.conversationDetails.value?.participants?.isEmpty ?? true) {
      return;
    }

    //
    // add reacted by models in the reactions list
    for (var reaction in message.reactions!) {
      //
      // finding participant
      final participant = controller.conversationDetails.value!.participants!
          .firstWhereOrNull((participant) =>
              ((participant.pId == reaction.pId) && (participant.pId != null)));

      if (participant != null) {
        reaction.reactedBy = participant;
      }
    }
  }
}

class _ReactionListItemView extends GetView<ChatDetailController> {
  final MessageReactionEntity reaction;
  final int index;
  final ConversationsController? conversationsController;
  const _ReactionListItemView({
    required this.reaction,
    required this.index,
    this.conversationsController,
  });

  @override
  Widget build(BuildContext context) {
    //
    // theme data
    final ThemeData theme = Theme.of(context);

    //
    // reacted by
    final ConversationWithParticipentEntity? reactedBy = reaction.reactedBy;

    //
    return Container(
      margin: index == 0
          ? const EdgeInsets.only(left: 1, right: 1, top: 14)
          : const EdgeInsets.symmetric(horizontal: 1),
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          //
          //
          // user image
          Stack(
            children: [
              SizedBox(
                width: 45,
                height: 45,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    reactedBy?.image ??
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDwmG52pVI5JZfn04j9gdtsd8pAGbqjjLswg&usqp=CAU",
                    width: 45,
                    height: 45,
                    errorBuilder: (context, error, stackTrace) => Image.network(
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDwmG52pVI5JZfn04j9gdtsd8pAGbqjjLswg&usqp=CAU"),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Icon(
                  Icons.circle,
                  size: 12,
                  color: (conversationsController?.isUserOnline(
                              reactedBy?.id, reactedBy?.modelType) ??
                          false)
                      ? AppColors.success
                      : context.offlineDotColor,
                ),
              )
            ],
          ),
          const SizedBox(width: 12),

          //
          //
          // other details
          Expanded(
            child: Text(
              ((reactedBy?.id?.toString() == controller.myId) &&
                      (reactedBy?.modelType == "applicants"))
                  ? "You"
                  : (reactedBy?.name ?? ""),
              style: theme.textTheme.bodyLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          //
          //
          // reaction

          Text(
            reaction.reaction ?? "",
            style: theme.textTheme.headlineSmall,
          )
        ],
      ),
    );
  }
}
