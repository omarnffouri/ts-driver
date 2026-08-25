import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/utils/message_input_formatter.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/resizable_emoji_gif_panel.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/message_components/reply_message_view.dart';
import '../../../controllers/chat_detail_controller.dart';

class ChatInputField extends GetView<ChatDetailController> {
  const ChatInputField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // built once so slot resizes don't rebuild the emoji/GIF grids
    final panel = ResizableEmojiGifPanel(controller: controller);
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: ((controller.selectedMessageForReply.value != null) ||
                    (controller.selectedAttachments.isNotEmpty))
                ? context.backgroundColor
                : Colors.transparent,
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 4),
                blurRadius: 32,
                color: context.chatInputShadowColor.applyOpacity(
                    controller.selectedAttachments.isNotEmpty ||
                            controller.selectedMessageForReply.value != null
                        ? 0.8
                        : 0),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Column(
              children: [
                const SizedBox(
                  height: 4,
                ),
                //
                //
                //
                Column(
                  children: [
                    //
                    //
                    // selected message view for reply
                    Obx(
                      () => controller.selectedMessageForReply.value != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ReplyMessageView(
                                  message:
                                      controller.selectedMessageForReply.value!,
                                  isSenderView: true,
                                ),

                                // close selected message button
                                GestureDetector(
                                  onTap: () {
                                    controller.selectedMessageForReply.value =
                                        null;
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(100))),
                                    child: const Icon(
                                      Icons.close,
                                      size: 15,
                                      color: AppColors.onPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),

                    //
                    //
                    // selected attachments view
                    Obx(
                      () => Visibility(
                        visible: controller.selectedAttachments.isNotEmpty,
                        child: SizedBox(
                          height: 70,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.selectedAttachments.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 60,
                                height: 80,
                                decoration: BoxDecoration(
                                    color: context.cardColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: context.dividerColor)),
                                child: Stack(children: [
                                  //
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Image.asset(
                                          controller.fileExtensionHelper
                                              .getFileIcon(
                                            controller.fileExtensionHelper
                                                .getFileType(
                                              controller
                                                      .selectedAttachments[
                                                          index]
                                                      .file
                                                      ?.path ??
                                                  "none",
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          controller.fileExtensionHelper
                                              .getFileName(controller
                                                      .selectedAttachments[
                                                          index]
                                                      .file
                                                      ?.path ??
                                                  ""),
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 10,
                                              color:
                                                  context.secondaryTextColor),
                                        ),
                                      )
                                    ],
                                  ).marginAll(5),

                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        controller.selectedAttachments
                                            .removeAt(index);
                                        if (controller
                                            .selectedAttachments.isEmpty) {
                                          controller.updateSendIcon();
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(100))),
                                        child: const Icon(
                                          Icons.close,
                                          size: 12,
                                          color: AppColors.onPrimary,
                                        ),
                                      ),
                                    ),
                                  )
                                ]),
                              ).marginOnly(left: 10);
                            },
                          ).marginOnly(bottom: 10),
                        ),
                      ),
                    ),

                    //
                    //
                    // message inpuit field and buttons
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.chatInputSurfaceColor,
                              boxShadow: [
                                BoxShadow(
                                  color: context.chatInputShadowColor,
                                  blurRadius: 6,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Obx(
                              () => Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  //
                                  //
                                  // emoji button
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 8, right: 8, bottom: 12),
                                    child: GestureDetector(
                                      onTap: () {
                                        controller.toggleEmojiPicker();
                                      },
                                      child: Icon(
                                        controller.isEmojiPickerVisible.value
                                            ? Icons.keyboard
                                            : Icons
                                                .sentiment_satisfied_alt_outlined,
                                        color: context.hintColor,
                                      ),
                                    ),
                                  ),

                                  //
                                  //
                                  // message input field
                                  Obx(
                                    () => Expanded(
                                      child: Scrollbar(
                                        child: TextField(
                                          controller:
                                              controller.richTextController,
                                          textInputAction:
                                              TextInputAction.newline,
                                          onSubmitted: (value) {
                                            controller.sendMessage();
                                          },
                                          inputFormatters: [
                                            MessageInputFormatter(),
                                          ],
                                          contextMenuBuilder:
                                              (context, editableTextState) {
                                            //
                                            //
                                            // text tool bar
                                            return AdaptiveTextSelectionToolbar(
                                              anchors: editableTextState
                                                  .contextMenuAnchors,
                                              children:
                                                  AdaptiveTextSelectionToolbar
                                                      .getAdaptiveButtons(
                                                context,
                                                [
                                                  //
                                                  //
                                                  // cut button
                                                  if (editableTextState
                                                      .cutEnabled)
                                                    ContextMenuButtonItem(
                                                      onPressed: () {
                                                        editableTextState
                                                            .cutSelection(
                                                                SelectionChangedCause
                                                                    .toolbar);
                                                      },
                                                      type:
                                                          ContextMenuButtonType
                                                              .cut,
                                                    ),

                                                  //
                                                  //
                                                  // copy button
                                                  if (editableTextState
                                                      .copyEnabled)
                                                    ContextMenuButtonItem(
                                                      onPressed: () {
                                                        editableTextState
                                                            .copySelection(
                                                                SelectionChangedCause
                                                                    .toolbar);
                                                      },
                                                      type:
                                                          ContextMenuButtonType
                                                              .copy,
                                                    ),

                                                  //
                                                  //
                                                  // past button
                                                  if (editableTextState
                                                      .pasteEnabled)
                                                    ContextMenuButtonItem(
                                                      onPressed: () {
                                                        editableTextState.pasteText(
                                                            SelectionChangedCause
                                                                .toolbar);
                                                      },
                                                      type:
                                                          ContextMenuButtonType
                                                              .paste,
                                                    ),

                                                  //
                                                  //
                                                  // share button
                                                  if (editableTextState
                                                      .shareEnabled)
                                                    ContextMenuButtonItem(
                                                      onPressed: () {
                                                        editableTextState
                                                            .shareSelection(
                                                                SelectionChangedCause
                                                                    .toolbar);
                                                      },
                                                      type:
                                                          ContextMenuButtonType
                                                              .share,
                                                    ),

                                                  //
                                                  //
                                                  // select all button
                                                  if (editableTextState
                                                      .selectAllEnabled)
                                                    ContextMenuButtonItem(
                                                      onPressed: () {
                                                        editableTextState.selectAll(
                                                            SelectionChangedCause
                                                                .toolbar);
                                                      },
                                                      type:
                                                          ContextMenuButtonType
                                                              .selectAll,
                                                    ),

                                                  //
                                                  //
                                                  // Bold button
                                                  if (editableTextState
                                                      .copyEnabled)
                                                    ContextMenuButtonItem(
                                                      onPressed: () =>
                                                          _applyTextFormat(
                                                              controller
                                                                  .richTextController,
                                                              '*'),
                                                      type:
                                                          ContextMenuButtonType
                                                              .custom,
                                                      label: 'Bold',
                                                    ),

                                                  //
                                                  //
                                                  // Italic button
                                                  if (editableTextState
                                                      .copyEnabled)
                                                    ContextMenuButtonItem(
                                                      onPressed: () =>
                                                          _applyTextFormat(
                                                              controller
                                                                  .richTextController,
                                                              '_'),
                                                      type:
                                                          ContextMenuButtonType
                                                              .custom,
                                                      label: 'Italic',
                                                    ),

                                                  //
                                                  //
                                                  // Strikethrough button
                                                  if (editableTextState
                                                      .copyEnabled)
                                                    ContextMenuButtonItem(
                                                      onPressed: () =>
                                                          _applyTextFormat(
                                                              controller
                                                                  .richTextController,
                                                              '~'),
                                                      type:
                                                          ContextMenuButtonType
                                                              .custom,
                                                      label: 'Strikethrough',
                                                    ),
                                                ],
                                              ).toList(),
                                            );
                                          },
                                          focusNode: controller.focusNode.value,
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          maxLines: 5,
                                          minLines: 1,
                                          decoration: InputDecoration(
                                              hintText: "Type message . . .",
                                              icon: controller
                                                      .haveImageInClipBoard
                                                      .value
                                                  ? GestureDetector(
                                                      onTap: () async {
                                                        controller
                                                            .attachFileFromClipboard();
                                                      },
                                                      child: const Icon(Icons
                                                          .content_paste_rounded),
                                                    ).paddingOnly(left: 10)
                                                  : null,
                                              border: InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              errorBorder: InputBorder.none,
                                              enabledBorder: InputBorder.none),
                                        ),
                                      ),
                                    ),
                                  ),

                                  //
                                  //
                                  // attachments button
                                  Container(
                                    margin: const EdgeInsets.only(
                                        right: 8, bottom: 12),
                                    child: Transform.rotate(
                                      angle: 2.5,
                                      child: GestureDetector(
                                        onTap: () {
                                          controller.showAttachmentBottomSheet(
                                              Get.theme);
                                        },
                                        child: Icon(
                                          Icons.attach_file,
                                          color: context.hintColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        //
                        //
                        // recording and send button
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          child: Obx(
                            () => InkWell(
                              onTap: () {
                                if (controller.recorderEnabled) {
                                  controller.showRecodingBottomSheet();
                                } else {
                                  controller.sendMessage();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                                child: AnimatedOpacity(
                                  opacity: controller.hideSendIcon ? 0.0 : 1.0,
                                  duration: const Duration(milliseconds: 100),
                                  child: Icon(
                                    controller.recorderEnabled
                                        ? Icons.mic
                                        : Icons.send,
                                    color: AppColors.onPrimary,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ).marginSymmetric(horizontal: 14, vertical: 5),
                // bottom slot the keyboard and panel share, so the input never jumps
                Obx(() {
                  final mq = MediaQuery.of(context);
                  final inset = controller.keyboardInset.value;
                  final navBottom = mq.viewPadding.bottom;
                  final showPicker = controller.isEmojiPickerVisible.value;
                  final panelH = controller.panelHeight.value;
                  final picker = showPicker ? panelH : navBottom;
                  final slot = inset > picker ? inset : picker;
                  return MediaQuery.removeViewInsets(
                    context: context,
                    removeBottom: true,
                    child: SizedBox(
                      width: double.infinity,
                      height: slot,
                      child: showPicker
                          ? ClipRect(
                              child: OverflowBox(
                                alignment: Alignment.topCenter,
                                minHeight: 0,
                                maxHeight: panelH,
                                child: SizedBox(height: panelH, child: panel),
                              ),
                            )
                          : null,
                    ),
                  );
                })
              ],
            ),
          ),
        ));
  }

  void _applyTextFormat(TextEditingController controller, String symbol) {
    final selection = controller.selection;

    if (selection.isCollapsed) {
      return; // No text selected
    }

    final text = controller.text;
    final selectedText = text.substring(selection.start, selection.end);

    // Apply the format
    final modifiedText = '$symbol$selectedText$symbol';
    final newText =
        text.replaceRange(selection.start, selection.end, modifiedText);

    // Update the text field with the formatted text
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
          offset: selection.start + modifiedText.length),
    );
  }
}
