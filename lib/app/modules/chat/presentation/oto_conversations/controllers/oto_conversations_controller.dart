import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/modules/chat/presentation/conversations/controllers/conversations_controller.dart';
import 'package:ts_driver/app/modules/chat/data/repositories/conversations_db_manager.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/conversation_entity.dart';
import 'package:ts_driver/app/modules/chat/domain/usecases/get_all_conversations_usecase.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';
import 'package:ts_driver/app/modules/main_screen/controllers/main_screen_controller.dart';
import 'package:ts_driver/app/core/services/injection_service.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';

class OtoConversationsController extends GetxController {
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  // one to one conversations list
  final conversations = RxList<ConversationEntity>();
  final filteredConversations = RxList<ConversationEntity>();

  final getAllConversationsUseCase = sl<GetAllConversationsUseCase>();

  // one to one conversations loading state
  final RxBool _isLoadingConversations = false.obs;
  bool get isLoadingConversations => _isLoadingConversations.value;

  // conversations from database loading state
  final RxBool _isLoadingConversationsFromDatabase = false.obs;
  bool get isLoadingConversationsFromDatabase =>
      _isLoadingConversationsFromDatabase.value;

  // conversations list empty from database
  final RxBool _isConversationsListEmptyFromDatabase = false.obs;
  bool get isConversationsListEmptyFromDatabase =>
      _isConversationsListEmptyFromDatabase.value;

  final RxBool isSearchEnabled = false.obs;

  final conversationsDatabase = sl<ConversationsDatabase>();

  final RxInt otoUnreadCounts = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadConversationsFromDatabase();

    conversations.listen((p0) {
      updateChatUnreadCountsForDependencies();
    });
  }

  loadConversationsFromDatabase() async {
    conversations.clear();
    try {
      _isLoadingConversationsFromDatabase(true);
      conversations.addAll(await conversationsDatabase.getAllConversations());
      _isLoadingConversationsFromDatabase(false);
      if (conversations.isEmpty) {
        _isConversationsListEmptyFromDatabase(true);
      }
    } catch (_) {
      _isLoadingConversationsFromDatabase(false);
    }
    getAllConversations();
  }

  Future<void> getAllConversations() async {
    try {
      _isLoadingConversations(true);
      final result = await getAllConversationsUseCase.call(const NoParams());
      result.fold((List<ConversationEntity> conversationsFromRemote) async {
        conversations.clear();
        conversations.value = conversationsFromRemote;

        try {
          await conversationsDatabase.deleteAllConversation();
          await conversationsDatabase.insertConversations(conversations);
        } catch (_) {}
      }, (Failure r) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: r.message,
        );
      });
      _isLoadingConversations(false);
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      debugPrint(e.toString());
      _isLoadingConversations(false);
    }
  }

  moveConversationOnTop(
      int conversationId, ConversationLastMessageEntity lastMessage,
      {bool incrementUnread = false}) {
    int? conversationIndex;
    int? filteredConversationIndex;

    // finding item and updating unread count and last seen time in conversations list
    for (int i = 0; i < conversations.length; i++) {
      if (conversations[i].id == conversationId) {
        conversations[i].dateTimeInHumans = "1 second ago";
        if (incrementUnread) {
          conversations[i].unreadCount =
              ((conversations[i].unreadCount ?? 0) + 1);
        }
        conversations[i].message = lastMessage;
        conversationIndex = i;
        if (i == 0) {
          conversations.refresh();
        }
        break;
      }
    }

    // checking if conversation is found in conversations list then move that index item to 0 index
    if (conversationIndex != null) {
      if (conversationIndex > 0 && conversationIndex < conversations.length) {
        final itemToMove = conversations[conversationIndex];
        conversations.removeAt(conversationIndex);
        conversations.insert(0, itemToMove);
      }
    }

    // finding item and updating unread count and last seen time in filtered conversations list
    for (int i = 0; i < filteredConversations.length; i++) {
      if (filteredConversations[i].id == conversationId) {
        filteredConversations[i].dateTimeInHumans = "1 second ago";
        filteredConversations[i].message = lastMessage;
        filteredConversationIndex = i;
        if (i == 0) {
          filteredConversations.refresh();
        }
        break;
      }
    }

    // checking if conversation is found in filtered conversations list then move that index item to 0 index
    if (filteredConversationIndex != null) {
      if (filteredConversationIndex > 0 &&
          filteredConversationIndex < filteredConversations.length) {
        final itemToMove = filteredConversations[filteredConversationIndex];
        filteredConversations.removeAt(filteredConversationIndex);
        filteredConversations.insert(0, itemToMove);
      }
    }
  }

  onMessageDelete(int conversationId, int messageId) {
    int? conversationIndex;
    int? filteredConversationIndex;

    // finding item and updating unread count and last seen time in conversations list
    for (int i = 0; i < conversations.length; i++) {
      if (conversations[i].id == conversationId) {
        if (conversations[i].message?.id == messageId) {
          conversations[i].dateTimeInHumans = "1 second ago";
          conversations[i].message?.deletedAt = DateTime.now();
          conversationIndex = i;
          if (i == 0) {
            conversations.refresh();
          }
        }
        break;
      }
    }

    // checking if conversation is found in conversations list then move that index item to 0 index
    if (conversationIndex != null) {
      if (conversationIndex > 0 && conversationIndex < conversations.length) {
        final itemToMove = conversations[conversationIndex];
        conversations.removeAt(conversationIndex);
        conversations.insert(0, itemToMove);
      }
    }

    // finding item and updating unread count and last seen time in filtered conversations list
    for (int i = 0; i < filteredConversations.length; i++) {
      if (filteredConversations[i].id == conversationId) {
        if (filteredConversations[i].message?.id == messageId) {
          filteredConversations[i].dateTimeInHumans = "1 second ago";
          filteredConversations[i].message?.deletedAt = DateTime.now();
          filteredConversationIndex = i;
          if (i == 0) {
            filteredConversations.refresh();
          }
        }
        break;
      }
    }

    // checking if conversation is found in filtered conversations list then move that index item to 0 index
    if (filteredConversationIndex != null) {
      if (filteredConversationIndex > 0 &&
          filteredConversationIndex < filteredConversations.length) {
        final itemToMove = filteredConversations[filteredConversationIndex];
        filteredConversations.removeAt(filteredConversationIndex);
        filteredConversations.insert(0, itemToMove);
      }
    }
  }

  setConversationUnreadCountToZero(int conversationId) {
    // finding item and updating unread count and last seen time in conversations list
    for (int i = 0; i < conversations.length; i++) {
      if (conversations[i].id == conversationId) {
        conversations[i].unreadCount = 0;
        conversations.refresh();
        break;
      }
    }
  }

  //
  //
  // search by firstname, lastname, name, phone
  void applySearch(String query) {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    isSearchEnabled(true);

    filteredConversations.clear();
    filteredConversations.addAll(conversations.where((item) {
      final firstName =
          item.user?.firstName?.toLowerCase().contains(query.toLowerCase()) ??
              false;
      final lastName =
          item.user?.lastName?.toLowerCase().contains(query.toLowerCase()) ??
              false;
      final phone =
          item.user?.phone?.toLowerCase().contains(query.toLowerCase()) ??
              false;
      final name =
          item.user?.name?.toLowerCase().contains(query.toLowerCase()) ?? false;
      return firstName || lastName || phone || name;
    }));
  }

  //
  //
  //
  void clearSearch() {
    FocusManager.instance.primaryFocus?.unfocus();
    isSearchEnabled(false);
    filteredConversations.clear();
    filteredConversations.addAll(conversations);
  }

  String _formatDuration(int totalTicks) {
    var tick = totalTicks;
    // // calculating days from tick
    // days.value = tick ~/ (24 * 3600);

    // // subracting days from the tick
    // tick = tick % (24 * 3600);

    // calculating hours
    final hours = tick ~/ 3600;

    // subracting hours from tick
    tick = tick % 3600;

    // calculating minutes
    final minutes = tick ~/ 60;

    // removing minutes and getting seconds
    final seconds = tick % 60;
    String duration =
        "${hours <= 9 ? '0' : ''}$hours-${minutes <= 9 ? '0' : ''}$minutes-${seconds <= 9 ? '0' : ''}$seconds";
    return duration;
  }

  String getCallText(
      int? callPlacedBy, String conversationType, String event, int? duration) {
    //
    if (conversationType == "group") {
      //
      return "group call";
    } else {
      //
      switch (event) {
        //
        // event the call status is not updated
        case AgoraCallEvents.incommingCall:
          return "Missed.";
        //
        // event the call is declined
        case AgoraCallEvents.callDeclined:
          return "Declined.";
        //
        // event the call is not answered
        case AgoraCallEvents.noAnswer:
          return "Not Answered.";
        //
        // event the call is not answered
        case AgoraCallEvents.callEnded:
          return duration != null ? _formatDuration(duration) : "";

        default:
          return "Missed.";
      }
    }
  }

  String formatAudioMessageDuration(int audioDuration) {
    var tick = audioDuration;

    // calculating minutes
    final minutes = tick ~/ 60;

    // removing minutes and getting seconds
    final seconds = tick % 60;
    String duration =
        "${minutes <= 9 ? '0' : ''}$minutes:${seconds <= 9 ? '0' : ''}$seconds";
    return duration;
  }

  //
  //
  //
  updateChatUnreadCountsForDependencies() {
    otoUnreadCounts.value = conversations.isEmpty
        ? 0
        : conversations
            .map((e) => e.unreadCount ?? 0)
            .reduce((value, e) => value + e);

    try {
      Get.find<MainScreenController>().updateUnreadMessageCounts();
    } catch (_) {}
    try {
      Get.find<ConversationsController>().updateOtoUnreadCounts();
    } catch (_) {}
  }
}
