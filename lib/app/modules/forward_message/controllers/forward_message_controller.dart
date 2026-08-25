import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/controllers/auth_controller.dart';

import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/message_file_helper.dart';
import 'package:ts_driver/app/core/values/constants.dart';
import 'package:ts_driver/app/modules/chat/presentation/group_conversations/controllers/group_conversations_controller.dart';
import 'package:ts_driver/app/modules/chat/presentation/oto_conversations/controllers/oto_conversations_controller.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/forward_message_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/params/forward_message_params.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/usecases/forward_message_usecase.dart';
import 'package:ts_driver/app/modules/chat/data/models/conversation_model.dart';
import 'package:ts_driver/app/modules/chat/data/models/group_conversation_model.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/conversation_entity.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/group_conversation_entity.dart';
import 'package:ts_driver/app/core/services/injection_service.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

class ForwardMessageController extends GetxController
    implements TickerProvider {
  late TabController tabController;

  RxList<ConversationMessageEntity> messages = RxList();

  final Rx<ForwardMessageTabs> currentTab = ForwardMessageTabs.chat.obs;

  final AuthController authController = Get.find<AuthController>();
  final forwardMessageUsecase = sl<ForwardMessageUseCase>();

  TextEditingController searchTextController = TextEditingController();
  TextEditingController innerSearchTextController = TextEditingController();

  // oto conversations list
  final conversations = RxList<ConversationEntity>();
  final filteredConversations = RxList<ConversationEntity>();

  // group conversations list
  final groupConversations = RxList<GroupConversationEntity>();
  final filteredGroupConversations = RxList<GroupConversationEntity>();

  // selected oto conversations
  final RxList<int> selectedConversations = RxList<int>();

  // selected group conversations
  final RxList<int> selectedGroupConversations = RxList<int>();

  final RxInt expandedGroupHead = (-1).obs;
  final String myId = CommonVariables.settings.read(APPLICANT_ID);

  // states
  final RxBool isSearchEnabled = false.obs;
  final RxBool isForwarding = false.obs;

  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      searchTextController.clear();
      if (tabController.index == 0) {
        currentTab(ForwardMessageTabs.chat);
      } else {
        currentTab(ForwardMessageTabs.group);
      }
    });

    try {
      messages.value = Get.arguments as List<ConversationMessageEntity>;
    } catch (_) {}

    if (messages.isEmpty) {
      Get.back();
    }

    // cheking if conversations controller is registered then copy
    // the convesations and group conversations list
    try {
      if (Get.isRegistered<OtoConversationsController>()) {
        // copying conversations
        conversations
            .addAll(Get.find<OtoConversationsController>().conversations);
      }

      if (Get.isRegistered<GroupConversationsController>()) {
        // copying group conversations
        groupConversations.addAll(
            Get.find<GroupConversationsController>().groupConversations);
      }
    } catch (_) {}
    super.onInit();
  }

  // handling when tap on one to one conversation
  onConversationTap(int? id) {
    if (id == null) {
      return;
    }
    if (selectedConversations.contains(id)) {
      selectedConversations.remove(id);
    } else if (getSelectedConversationsCount() < 5) {
      selectedConversations.add(id);
    } else {
      CommonWidgets.showSnackBar(
        title: "",
        message: "Can forward only 5 conversations.",
        isError: false,
      );
    }
  }

  // handling when tap on group conversation
  onGroupConversationTap(int? id) {
    if (id == null) {
      return;
    }
    if (selectedGroupConversations.contains(id)) {
      selectedGroupConversations.remove(id);
    } else if (getSelectedConversationsCount() < 5) {
      selectedGroupConversations.add(id);
    } else {
      CommonWidgets.showSnackBar(
        title: "",
        message: "Can forward only 5 conversations.",
        isError: false,
      );
    }
  }

  List<int> _getSelectedConversations() {
    List<int> list = [];
    list.addAll(selectedConversations);
    list.addAll(selectedGroupConversations);
    return list;
  }

  int getSelectedConversationsCount() {
    int count = 0;
    count += selectedConversations.length;
    count += selectedGroupConversations.length;
    return count;
  }

  void clearSearch() {
    searchTextController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // applying search in the bases of selected tab and add then to filtered list
  // search by firstname, lastname, name, phone
  void applySearch() {
    isSearchEnabled(true);
    // if active tab is chat then apply search on the conversations
    if (currentTab.value == ForwardMessageTabs.chat) {
      filteredConversations.clear();
      filteredConversations.addAll(conversations.where((item) {
        final phone = item.user?.phone
                ?.toLowerCase()
                .contains(searchTextController.text.toString().toLowerCase()) ??
            false;
        final name = item.user?.name
                ?.toLowerCase()
                .contains(searchTextController.text.toString().toLowerCase()) ??
            false;
        return phone || name;
      }));
    }

    // if active tab is group then apply search on group conversations list
    else if (currentTab.value == ForwardMessageTabs.group) {
      filteredGroupConversations.clear();
      filteredGroupConversations.addAll(groupConversations.where((item) {
        final nameCheck = item.name
                ?.toLowerCase()
                .contains(searchTextController.text.toString().toLowerCase()) ??
            false;
        return nameCheck;
      }));
    }
  }

  String getSelectedConversationsName() {
    String names = "";

    // checking for the selected oto conversations and filtering names
    if (selectedConversations.isNotEmpty) {
      final cons =
          conversations.where((p0) => selectedConversations.contains(p0.id));
      names = cons
          .map((e) => (e.user?.name ?? ""))
          .toString()
          .replaceAll('(', '')
          .replaceAll(')', '');
    }

    if (selectedGroupConversations.isNotEmpty) {
      final groupNames = groupConversations
          .where((p0) => selectedGroupConversations.contains(p0.id))
          .map((e) => (e.name ?? ""))
          .toString()
          .replaceAll('(', '')
          .replaceAll(')', '');
      if (groupNames.isNotEmpty) {
        if (names.isEmpty) {
          names = groupNames;
        } else {
          names += ", $groupNames";
        }
      }
    }
    return names;
  }

  forwardMessage(ConversationMessageEntity message) async {
    //
    //
    if (getSelectedConversationsCount() < 1) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: "Please select at least one conversation.",
      );
      return;
    }
    //
    //
    try {
      isForwarding(true);
      final Either<ForwardMessageEntity, Failure> result =
          await forwardMessageUsecase.call(
        ForwardMessageParams(
          messageId: message.id!,
          conversations: _getSelectedConversations(),
        ),
      );
      isForwarding(false);
      result.fold((ForwardMessageEntity forwadedMessage) {
        if (forwadedMessage.code == 200) {
          //
          // sorting conversations lists on the bases of forwaded last message

          try {
            message.createdAt = DateTime.now();

            if (Get.isRegistered<OtoConversationsController>()) {
              // checking and sorting oto conversations
              if (selectedConversations.isNotEmpty) {
                for (var element in selectedConversations) {
                  Get.find<OtoConversationsController>().moveConversationOnTop(
                      element,
                      ConversationLastMessageModel.fromJson(message.toJson()));
                }
              }
            }

            if (Get.isRegistered<GroupConversationsController>()) {
              // checking and sorting group conversations
              if (selectedGroupConversations.isNotEmpty) {
                for (var element in selectedGroupConversations) {
                  Get.find<GroupConversationsController>()
                      .moveGroupConversationOnTop(element,
                          GroupMessageModel.fromJson(message.toJson()));
                }
              }
            }
          } catch (_) {}

          //
          //
          if (message.id! == messages.last.id!) {
            Get.back();
            CommonWidgets.showSnackBar(
                title: 'Success'.tr,
                message:
                    "Message${messages.length > 1 ? "'s" : ""} forwarded successfully.",
                isError: false);
          }
        } else {
          CommonWidgets.showSnackBar(
            title: 'Error'.tr,
            message: forwadedMessage.message ?? "Something went wrong.",
          );
        }
      }, (Failure r) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: r.message,
        );
      });
      isForwarding(false);
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      debugPrint(e.toString());
      isForwarding(false);
    }
  }

  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '$hours:${_twoDigits(minutes)}:${_twoDigits(remainingSeconds)}';
    } else {
      return '${_twoDigits(minutes)}:${_twoDigits(remainingSeconds)}';
    }
  }

  String _twoDigits(int n) {
    if (n >= 10) {
      return '$n';
    } else {
      return '0$n';
    }
  }

  String getFileType(String fileExt) {
    if (MessageFileType.types.contains(fileExt.toLowerCase())) {
      return fileExt.toLowerCase();
    } else {
      return MessageFileType.none;
    }
  }

  String getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case MessageFileType.doc:
        return Assets.chatIcons.doc.path;
      case MessageFileType.docx:
        return Assets.chatIcons.docx.path;
      case MessageFileType.ppt:
        return Assets.chatIcons.ppt.path;
      case MessageFileType.pptx:
        return Assets.chatIcons.pptx.path;
      case MessageFileType.xls:
        return Assets.chatIcons.xls.path;
      case MessageFileType.xlsx:
        return Assets.chatIcons.xlsx.path;
      case MessageFileType.pdf:
        return Assets.chatIcons.pdf.path;
      case MessageFileType.txt:
        return Assets.chatIcons.txt.path;
      case MessageFileType.odt:
        return Assets.chatIcons.odt.path;
      case MessageFileType.html:
        return Assets.chatIcons.html.path;
      case MessageFileType.zip:
        return Assets.chatIcons.zip.path;
      case MessageFileType.mp3:
        return Assets.chatIcons.audio.path;
      case MessageFileType.audio:
        return Assets.chatIcons.audio.path;
      case MessageFileType.mp4:
        return Assets.chatIcons.video.path;
      case MessageFileType.webm:
        return Assets.chatIcons.video.path;
      case MessageFileType.mpeg:
        return Assets.chatIcons.video.path;
      case MessageFileType.png:
        return Assets.chatIcons.image.path;
      case MessageFileType.jpg:
        return Assets.chatIcons.image.path;
      case MessageFileType.jpeg:
        return Assets.chatIcons.image.path;
      default:
        return Assets.chatIcons.none.path;
    }
  }

  String getFileNameWithExtenshion(String filePath) {
    var paths = filePath.split("/");
    if (paths.isNotEmpty) {
      return paths.last;
    } else {
      return "Unkown";
    }
  }

  String getFileExtension(String fileName) {
    var names = fileName.split(".");
    if (names.isNotEmpty) {
      return names.last;
    } else {
      return "none";
    }
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}

enum ForwardMessageTabs { chat, group }
