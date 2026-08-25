import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:ts_driver/app/core/widgets/base_screen.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/app_bar_components/call_action_icons.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/buzz_components/conversation_buzz_view.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/chat_input_field.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/message_main_view.dart';
import 'package:ts_driver/app/modules/chat/presentation/conversations/controllers/conversations_controller.dart';
import 'package:ts_driver/app/core/widgets/profile_image.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';
import '../../../../theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import '../../../../core/utils/widget_utils.dart';
import '../../../../core/widgets/app_text.dart';
import '../controllers/chat_detail_controller.dart';

part './components/body_components/search_buttons_view.dart';
part './components/app_bar_components/message_action_icons.dart';
part './components/app_bar_components/search_action_icon.dart';
part './components/app_bar_components/chat_app_bar_title.dart';
part './components/body_components/syncing_messages_indication.dart';

class ChatDetailView extends GetView<ChatDetailController> {
  const ChatDetailView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light
          .copyWith(statusBarIconBrightness: Brightness.dark),
    );
    // read above the Scaffold (the body below consumes it to 0) for the slot
    final kbInset = MediaQuery.viewInsetsOf(context).bottom;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.setKeyboardInset(kbInset));
    return
        // ignore: deprecated_member_use
        WillPopScope(
            onWillPop: () async {
              Get.back(result: true);
              return false;
            },
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: context.isDark
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark,
                child: BaseScreen(
                  // the chat's bottom slot owns keyboard space (both Scaffolds)
                  resizeToAvoidBottomInset: false,
                  child: GestureDetector(
                    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                    child: Scaffold(
                      resizeToAvoidBottomInset: false,
                      body: Container(
                        color: context.chatCanvasColor,
                        child: Stack(
                          children: [
                            //
                            //
                            // chat background
                            Positioned.fill(
                              child: Image.asset(
                                Assets.chatIcons.chatBackgroundCover.path,
                                fit: BoxFit.cover,
                                opacity: const AlwaysStoppedAnimation(0.2),
                              ),
                            ),

                            //
                            // messages list and message input body etc

                            Obx(
                              () =>
                                  ((controller.isLoadingChatDetails &&
                                              controller.isDatabaseListEmpty) ||
                                          controller.isLoadingFromDatabase)
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                              color: AppColors.primary),
                                        )
                                      : SafeArea(
                                          top: false,
                                          // nav-bar clearance handled by the bottom slot
                                          bottom: false,
                                          child: Column(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.only(
                                                    top: MediaQuery.of(context)
                                                        .padding
                                                        .top,
                                                    bottom: 8),
                                                decoration: BoxDecoration(
                                                  color: context.panelColor,
                                                  boxShadow: context.cardShadow,
                                                ),
                                                child: SizedBox(
                                                  height: 60,
                                                  child: Row(
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(
                                                            Icons
                                                                .arrow_back_ios,
                                                            color: context
                                                                .primaryTextColor),
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                      ),
                                                      const Expanded(
                                                        child:
                                                            _ChatAppBarTitle(),
                                                      ),
                                                      const _SearchMessagesActionIcon()
                                                          .marginOnly(
                                                              right: 15),
                                                      const CallActionIcons(),
                                                      const _MessageActionIcons(),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              //
                                              //
                                              // buttons to scroll next and previous searched messages
                                              const _SearchButtonsView(),

                                              //
                                              //
                                              //
                                              Expanded(
                                                child: Stack(
                                                  children: [
                                                    Obx(
                                                      () => NotificationListener<
                                                          OverscrollIndicatorNotification>(
                                                        onNotification:
                                                            (overscroll) {
                                                          overscroll
                                                              .disallowIndicator(); // Remove overscroll effect
                                                          return false;
                                                        },
                                                        child: ScrollablePositionedList
                                                            .builder(
                                                                reverse: true,
                                                                physics:
                                                                    const ClampingScrollPhysics(),
                                                                itemScrollController:
                                                                    controller
                                                                        .scrollController,
                                                                itemCount:
                                                                    controller
                                                                        .messages
                                                                        .length,
                                                                itemPositionsListener:
                                                                    controller
                                                                        .itemPositionsNotifier,
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  var message =
                                                                      controller
                                                                              .messages[
                                                                          index];

                                                                  final key =
                                                                      ValueKey(
                                                                    'msg_${message.id ?? message.tempId ?? index}',
                                                                  );

                                                                  // this variable shows that list have a next index or not
                                                                  bool nextIndexExists = (index +
                                                                          1) <
                                                                      controller
                                                                          .messages
                                                                          .length;

                                                                  // this represents the current index message date
                                                                  final currentMessageDate = DateFormat(
                                                                          'MMMM d, y')
                                                                      .format(message
                                                                              .createdAt ??
                                                                          DateTime
                                                                              .now());

                                                                  // this will represent the next index message date
                                                                  var nextMessageDate =
                                                                      currentMessageDate;

                                                                  // checking if next index exists then update the nextMessageDate variable with next message date
                                                                  if (nextIndexExists) {
                                                                    nextMessageDate = DateFormat('MMMM d, y').format(controller
                                                                            .messages[index +
                                                                                1]
                                                                            .createdAt ??
                                                                        DateTime
                                                                            .now());
                                                                  }

                                                                  if ((index ==
                                                                          (controller.messages.length -
                                                                              1)) &&
                                                                      (!controller
                                                                          .isLoadingPreviousMessages) &&
                                                                      (!controller
                                                                          .noMoreMessages)) {
                                                                    controller.loadPreviousMessages(
                                                                        message
                                                                            .id);
                                                                  }

                                                                  return Column(
                                                                    children: [
                                                                      //
                                                                      //
                                                                      // beginning of chat text
                                                                      if (controller
                                                                              .noMoreMessages &&
                                                                          (index ==
                                                                              (controller.messages.length - 1)))
                                                                        Container(
                                                                          margin: const EdgeInsets
                                                                              .only(
                                                                              top: 20),
                                                                          child:
                                                                              const AppText(
                                                                            text:
                                                                                "Begining of chat",
                                                                            color:
                                                                                AppColors.primary,
                                                                            size:
                                                                                14,
                                                                          ),
                                                                        ),

                                                                      //
                                                                      //
                                                                      // loading indicator
                                                                      if (controller
                                                                              .isLoadingPreviousMessages &&
                                                                          (index ==
                                                                              (controller.messages.length - 1)))
                                                                        Container(
                                                                          margin: const EdgeInsets
                                                                              .symmetric(
                                                                              vertical: 20),
                                                                          child:
                                                                              const SizedBox(
                                                                            width:
                                                                                30,
                                                                            height:
                                                                                30,
                                                                            child:
                                                                                CircularProgressIndicator(
                                                                              color: AppColors.primary,
                                                                            ),
                                                                          ),
                                                                        ),

                                                                      //
                                                                      //
                                                                      // date lable view
                                                                      if ((currentMessageDate !=
                                                                              nextMessageDate) ||
                                                                          (index ==
                                                                              (controller.messages.length - 1)))
                                                                        Container(
                                                                          margin: const EdgeInsets
                                                                              .only(
                                                                              top: 20,
                                                                              bottom: 10),
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              vertical: 5,
                                                                              horizontal: 10),
                                                                          decoration: BoxDecoration(
                                                                              color: context.dividerColor,
                                                                              borderRadius: BorderRadius.circular(8)),
                                                                          child:
                                                                              Text(
                                                                            currentMessageDate,
                                                                            style:
                                                                                TextStyle(color: context.secondaryTextColor),
                                                                          ),
                                                                        ),

                                                                      //
                                                                      //
                                                                      // actual message view
                                                                      _MessageItemView(
                                                                        key:
                                                                            key,
                                                                        message:
                                                                            message,
                                                                        index:
                                                                            index,
                                                                      ),
                                                                    ],
                                                                  );
                                                                }),
                                                      ),
                                                    ),

                                                    //
                                                    //
                                                    // scroll to bottom button
                                                    Obx(() => Visibility(
                                                          visible: controller
                                                              .showScrollDownButton
                                                              .value,
                                                          child: Positioned(
                                                            bottom: 14,
                                                            right: 14,
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                controller
                                                                    .scrollToMessageAtIndex(
                                                                        0);
                                                              },
                                                              child: const Icon(
                                                                Icons
                                                                    .expand_circle_down_rounded,
                                                                size: 30,
                                                                color: AppColors
                                                                    .primary,
                                                              ),
                                                            ),
                                                          ),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              //
                                              //
                                              // indicates the message syncing from server
                                              const _SyncingMessagesIndication(),

                                              //
                                              //
                                              // message input field
                                              controller.chatable == false
                                                  ? Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                        vertical: 24,
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 12,
                                                        vertical: 12,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          10,
                                                        ),
                                                        color: AppColors.primary
                                                            .withValues(
                                                                alpha: 0.75),
                                                      ),
                                                      child: const Text(
                                                        "You’re not able to talk in this conversation.",
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .onPrimary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    )
                                                  : Visibility(
                                                      visible:
                                                          controller.chatable,
                                                      child:
                                                          const ChatInputField()),
                                            ],
                                          ),
                                        ),
                            ),

                            //
                            //
                            // buzz view
                            Obx(
                              () => Visibility(
                                visible: controller.receivedBuzz &&
                                    (controller.buzzOnMessageId.value == null),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.10),
                                  ),
                                  child: const ConversationBuzzView(
                                    size: 450,
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
            ));
  }
}

class _MessageItemView extends GetView<ChatDetailController> {
  final ConversationMessageEntity message;
  final int index;
  const _MessageItemView({Key? key, required this.message, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: message.id != null
          ? message.id!.toString()
          : message.tempId != null
              ? message.tempId!
              : controller.generateUid().toString(),
      child: Obx(
        () => Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),
            color: controller.currentSearchedIndex.value == index ||
                    (controller.isMessageSelectionEnabled &&
                        controller.selectedMessages.contains(message.id)) ||
                    (controller.messageTempHighlightEnabled &&
                        (controller.tempHighlightMessageId.value == message.id))
                ? AppColors.primary.withValues(alpha: 0.10)
                : Colors.transparent,
            child: MessageMainView(
              message: message,
              index: index,
            ),
          ),
        ),
      ),
    );
  }
}
