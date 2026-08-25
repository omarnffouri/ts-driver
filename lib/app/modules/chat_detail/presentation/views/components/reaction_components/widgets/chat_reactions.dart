library flutter_chat_reactions;

import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/emoji_picker.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/reaction_components/model/reactions_menu_item.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/reaction_components/utilities/reactions_default_data.dart';

class ReactionsDialogWidget extends StatefulWidget {
  const ReactionsDialogWidget({
    super.key,
    required this.id,
    required this.messageWidget,
    required this.onReactionTap,
    required this.onContextMenuTap,
    this.menuItems = ReactionsData.menuItems,
    this.reactions = ReactionsData.reactions,
    this.widgetAlignment = Alignment.centerRight,
    this.menuItemsWidth = 0.45,
    this.menuItemsPadding = const EdgeInsets.all(0),
  });

  // Id for the hero widget
  final String id;

  // The message widget to be displayed in the dialog
  final Widget messageWidget;

  // The callback function to be called when a reaction is tapped
  final Function(String) onReactionTap;

  // The callback function to be called when a context menu item is tapped
  final Function(ReactionsMenuItem) onContextMenuTap;

  // The list of menu items to be displayed in the context menu
  final List<ReactionsMenuItem> menuItems;

  // The list of reactions to be displayed
  final List<String> reactions;

  // The alignment of the widget
  final Alignment widgetAlignment;

  // The width of the menu items
  final double menuItemsWidth;

  // The padding of the menu item
  final EdgeInsetsGeometry menuItemsPadding;

  @override
  State<ReactionsDialogWidget> createState() => _ReactionsDialogWidgetState();
}

class _ReactionsDialogWidgetState extends State<ReactionsDialogWidget> {
  // state variables for activating the animation
  bool reactionClicked = false;
  bool showMoreReactions = false;
  int? clickedReactionIndex;
  int? clickedContextMenuIndex;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //
            // spacer
            if (showMoreReactions) const Spacer(),

            Column(
              children: [
                // reactions
                buildReactions(context),
                const SizedBox(
                  height: 10,
                ),
                // message
                buildMessage(),
                const SizedBox(
                  height: 10,
                ),
                // context menu
                buildMenuItems(context),
              ],
            ).marginSymmetric(horizontal: 20),

            if (showMoreReactions) const Spacer(),

            //
            // building emoji picker view

            AnimatedContainer(
              height: showMoreReactions ? 300.h : 0,
              duration: const Duration(milliseconds: 300),
              child: showMoreReactions ? buildEmojiPicker() : null,
            )
          ],
        ),
      ),
    );
  }

  Align buildMenuItems(BuildContext context) {
    return Align(
      alignment: widget.widgetAlignment,
      child: // contextMenu for reply, copy, delete
          Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * widget.menuItemsWidth,
          padding: widget.menuItemsPadding,
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: context.cardShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var item in widget.menuItems)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                      child: InkWell(
                        onTap: () {
                          final navigator = Navigator.of(context);
                          // set the clicked index for animation
                          setState(() {
                            clickedContextMenuIndex =
                                widget.menuItems.indexOf(item);
                          });

                          // delay for 200 milliseconds to allow the animation to complete
                          Future.delayed(const Duration(milliseconds: 500))
                              .whenComplete(() {
                            // pop the dialog
                            navigator.pop();
                            widget.onContextMenuTap(item);
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.label,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color:
                                        item.isDestuctive ? Colors.red : null,
                                  ),
                            ),
                            Pulse(
                              infinite: false,
                              duration: const Duration(milliseconds: 500),
                              animate: clickedContextMenuIndex ==
                                  widget.menuItems.indexOf(item),
                              child: item.customIcon ??
                                  Icon(
                                    item.icon,
                                    color: item.isDestuctive
                                        ? Colors.red
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                  ),
                            )
                          ],
                        ),
                      ),
                    ),
                    if (widget.menuItems.last != item)
                      Divider(
                        color: context.dividerColor,
                        thickness: 1,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Align buildMessage() {
    return Align(
      alignment: widget.widgetAlignment,
      child: Hero(
        tag: widget.id,
        child: widget.messageWidget,
      ),
    );
  }

  Align buildReactions(BuildContext context) {
    return Align(
      alignment: widget.widgetAlignment,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: context.cardShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var reaction in widget.reactions)
                FadeInLeft(
                  from: // first index should be from 0, second from 20, third from 40 and so on
                      0 + (widget.reactions.indexOf(reaction) * 20).toDouble(),
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 200),
                  child: InkWell(
                      onTap: () {
                        if (reaction == '➕') {
                          setState(() {
                            showMoreReactions = true;
                          });
                          return;
                        }

                        final navigator = Navigator.of(context);
                        setState(() {
                          reactionClicked = true;
                          clickedReactionIndex =
                              widget.reactions.indexOf(reaction);
                        });
                        // delay for 200 milliseconds to allow the animation to complete
                        Future.delayed(const Duration(milliseconds: 500))
                            .whenComplete(() {
                          // pop the dialog
                          navigator.pop();
                          widget.onReactionTap(reaction);
                        });
                      },
                      child: Pulse(
                        infinite: false,
                        duration: const Duration(milliseconds: 500),
                        animate: reactionClicked &&
                            clickedReactionIndex ==
                                widget.reactions.indexOf(reaction),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2),
                          child: Text(
                            reaction,
                            style: TextStyle(fontSize: 30.sp),
                          ),
                        ),
                      )),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmojiPicker() {
    return SizedBox(
      height: 290.h,
      child: EmojiPicker(
        onBackspacePressed: () {
          Get.back();
        },
        onEmojiSelected: (category, emoji) {
          widget.onReactionTap(emoji.emoji);
          Navigator.of(context).pop();
        },
        config: buildChatEmojiConfig(context, surface: context.sheetColor),
      ),
    );
  }
}
