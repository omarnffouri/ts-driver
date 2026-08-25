import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/controllers/auth_controller.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/modules/chat/presentation/conversations/controllers/conversations_controller.dart';
import 'package:ts_driver/app/modules/chat/data/repositories/conversations_db_manager.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/group_conversation_entity.dart';
import 'package:ts_driver/app/modules/chat/domain/usecases/get_all_group_conversations_usecase.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';
import 'package:ts_driver/app/modules/main_screen/controllers/main_screen_controller.dart';
import 'package:ts_driver/app/core/services/injection_service.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';

class GroupConversationsController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  final getAllGroupConversationsUseCase = sl<GetAllGroupConversationsUseCase>();

  RefreshController groupConversationsRefreshController =
      RefreshController(initialRefresh: false);

  // group conversations lists
  final groupConversations = RxList<GroupConversationEntity>();
  final filteredGroupConversations = RxList<GroupConversationEntity>();

// group conversations loading state
  final RxBool _isLoadingGroupConversations = false.obs;
  bool get isLoadingGroupConversations => _isLoadingGroupConversations.value;

  // group conversations from database loading state
  final RxBool _isLoadingGroupConversationsFromDatabase = false.obs;
  bool get isLoadingGroupConversationsFromDatabase =>
      _isLoadingGroupConversationsFromDatabase.value;

  // group conversations list empty from database
  final RxBool _isGroupConversationsListEmptyFromDatabase = false.obs;
  bool get isGroupConversationsListEmptyFromDatabase =>
      _isGroupConversationsListEmptyFromDatabase.value;

  final conversationsDatabase = sl<ConversationsDatabase>();

  final RxBool isSearchEnabled = false.obs;

  final RxInt groupUnreadCounts = 0.obs;

  @override
  void onInit() {
    super.onInit();

    loadGroupConversationsFromDatabase();

    groupConversations.listen((p0) {
      updateChatUnreadCountsForDependencies();
    });
  }

  loadGroupConversationsFromDatabase() async {
    groupConversations.clear();
    try {
      _isLoadingGroupConversationsFromDatabase(true);
      groupConversations
          .addAll(await conversationsDatabase.getAllGroupConversations());
      _isLoadingGroupConversationsFromDatabase(false);
      if (groupConversations.isEmpty) {
        _isGroupConversationsListEmptyFromDatabase(true);
      }
    } catch (_) {
      _isLoadingGroupConversationsFromDatabase(false);
    }
    getAllGroupConversations();
  }

  Future<void> getAllGroupConversations() async {
    try {
      _isLoadingGroupConversations(true);
      final result =
          await getAllGroupConversationsUseCase.call(const NoParams());
      result.fold((List<GroupConversationEntity> groupConversationsData) async {
        groupConversations.clear();
        groupConversations.value = groupConversationsData;

        try {
          await conversationsDatabase.deleteAllGroupConversation();
          await conversationsDatabase
              .insertGroupConversations(groupConversations);
        } catch (_) {}
      }, (Failure r) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: r.message,
        );
      });
      _isLoadingGroupConversations(false);
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      debugPrint(e.toString());
      _isLoadingGroupConversations(false);
    }
  }

  moveGroupConversationOnTop(int conversationId, GroupMessageEntity lastMessage,
      {bool incrementUnread = false}) {
    int? groupConversationIndex;
    int? filteredGroupConversationIndex;

    // finding item and updating unread count and last seen time in conversations list
    for (int i = 0; i < groupConversations.length; i++) {
      if (groupConversations[i].id == conversationId) {
        groupConversations[i].dateTimeInHumans = "1 second ago";
        if (incrementUnread) {
          groupConversations[i].unreadCount =
              ((groupConversations[i].unreadCount ?? 0) + 1);
        }
        groupConversations[i].message = lastMessage;
        groupConversationIndex = i;
        if (i == 0) {
          groupConversations.refresh();
        }
        break;
      }
    }

    // checking if conversation is found in conversations list then move that index item to 0 index
    if (groupConversationIndex != null) {
      if (groupConversationIndex > 0 &&
          groupConversationIndex < groupConversations.length) {
        final itemToMove = groupConversations[groupConversationIndex];
        groupConversations.removeAt(groupConversationIndex);
        groupConversations.insert(0, itemToMove);
      }
    }

    // finding item and updating unread count and last seen time in filtered conversations list
    for (int i = 0; i < filteredGroupConversations.length; i++) {
      if (filteredGroupConversations[i].id == conversationId) {
        filteredGroupConversations[i].dateTimeInHumans = "1 second ago";
        filteredGroupConversations[i].message = lastMessage;
        filteredGroupConversationIndex = i;
        if (i == 0) {
          filteredGroupConversations.refresh();
        }
        break;
      }
    }

    // checking if conversation is found in filtered conversations list then move that index item to 0 index
    if (filteredGroupConversationIndex != null) {
      if (filteredGroupConversationIndex > 0 &&
          filteredGroupConversationIndex < filteredGroupConversations.length) {
        final itemToMove =
            filteredGroupConversations[filteredGroupConversationIndex];
        filteredGroupConversations.removeAt(filteredGroupConversationIndex);
        filteredGroupConversations.insert(0, itemToMove);
      }
    }
  }

  onMessageDelete(int conversationId, int messageId,
      {bool incrementUnread = false}) {
    int? groupConversationIndex;
    int? filteredGroupConversationIndex;

    // finding item and updating unread count and last seen time in conversations list
    for (int i = 0; i < groupConversations.length; i++) {
      if (groupConversations[i].id == conversationId) {
        if (groupConversations[i].message?.id == messageId) {
          groupConversations[i].dateTimeInHumans = "1 second ago";
          groupConversations[i].message?.deletedAt = DateTime.now();
          groupConversationIndex = i;
        }
        if (i == 0) {
          groupConversations.refresh();
        }
        break;
      }
    }

    // checking if conversation is found in conversations list then move that index item to 0 index
    if (groupConversationIndex != null) {
      if (groupConversationIndex > 0 &&
          groupConversationIndex < groupConversations.length) {
        final itemToMove = groupConversations[groupConversationIndex];
        groupConversations.removeAt(groupConversationIndex);
        groupConversations.insert(0, itemToMove);
      }
    }

    // finding item and updating unread count and last seen time in filtered conversations list
    for (int i = 0; i < filteredGroupConversations.length; i++) {
      if (filteredGroupConversations[i].id == conversationId) {
        if (filteredGroupConversations[i].message?.id == messageId) {
          filteredGroupConversations[i].dateTimeInHumans = "1 second ago";
          filteredGroupConversations[i].message?.deletedAt = DateTime.now();
          filteredGroupConversationIndex = i;
        }
        if (i == 0) {
          filteredGroupConversations.refresh();
        }
        break;
      }
    }

    // checking if conversation is found in filtered conversations list then move that index item to 0 index
    if (filteredGroupConversationIndex != null) {
      if (filteredGroupConversationIndex > 0 &&
          filteredGroupConversationIndex < filteredGroupConversations.length) {
        final itemToMove =
            filteredGroupConversations[filteredGroupConversationIndex];
        filteredGroupConversations.removeAt(filteredGroupConversationIndex);
        filteredGroupConversations.insert(0, itemToMove);
      }
    }
  }

  //
  //
  // search by group name
  void applySearch(String query) {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    isSearchEnabled(true);
    filteredGroupConversations.clear();
    filteredGroupConversations.addAll(groupConversations.where((item) {
      final nameCheck =
          item.name?.toLowerCase().contains(query.toLowerCase()) ?? false;
      return nameCheck;
    }));
  }

  //
  //
  //
  void clearSearch() {
    FocusManager.instance.primaryFocus?.unfocus();
    isSearchEnabled(false);
    filteredGroupConversations.clear();
    filteredGroupConversations.addAll(groupConversations);
  }

  updateChatUnreadCountsForDependencies() {
    groupUnreadCounts.value = groupConversations.isEmpty
        ? 0
        : groupConversations
            .map((e) => e.unreadCount ?? 0)
            .reduce((value, e) => value + e);

    try {
      Get.find<MainScreenController>().updateUnreadMessageCounts();
    } catch (_) {}

    try {
      Get.find<ConversationsController>().updateGroupUnreadCounts();
    } catch (_) {}
  }

  setGroupConversationUnreadCountToZero(int conversationId) {
    // finding item and setting unread count to zero in group conversations list
    for (int i = 0; i < groupConversations.length; i++) {
      if (groupConversations[i].id == conversationId) {
        groupConversations[i].unreadCount = 0;
        groupConversations.refresh();
        break;
      }
    }
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
}
