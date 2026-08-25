import 'dart:async';
import 'dart:convert';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/controllers/auth_controller.dart';
import 'package:ts_driver/app/core/values/constants.dart';
import 'package:ts_driver/app/modules/chat/presentation/group_conversations/controllers/group_conversations_controller.dart';
import 'package:ts_driver/app/modules/chat/presentation/oto_conversations/controllers/oto_conversations_controller.dart';
import 'package:ts_driver/app/modules/chat_detail/data/repositories/messages_db_manager.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/pusher_manager.dart';
import 'package:ts_driver/app/modules/chat/data/models/presence_added_model.dart';
import 'package:ts_driver/app/modules/chat/data/models/presence_data_model.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/conversation_entity.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/group_conversation_entity.dart';
import 'package:ts_driver/app/core/services/injection_service.dart';

class ConversationsController extends GetxController {
  final Rx<ConversationTabs> currentTab = ConversationTabs.group.obs;

  TextEditingController searchTextController = TextEditingController();

  final pusher = sl<PusherManager>();

  final messagesDb = MessagesDatabase();

  final myId = CommonVariables.settings.read(APPLICANT_ID).toString();

  StreamSubscription<ChannelReadEvent>? messageNotificationSubscription;
  StreamSubscription<ChannelReadEvent>? newConversationCreatedSubscription;
  StreamSubscription<ChannelReadEvent>? onlineSubscriptionSucceededSubscription;
  StreamSubscription<ChannelReadEvent>? onlineUserAddedSubscription;
  StreamSubscription<ChannelReadEvent>? onlineUserRemovedSubscription;

  // list of the online user ids
  final RxList<OnlineUser> onlineUsers = RxList<OnlineUser>();

  final RxInt _otoUnreadCounts = 0.obs;
  int get otoUnreadCounts => _otoUnreadCounts.value;

  final RxInt _groupUnreadCounts = 0.obs;
  int get groupUnreadCounts => _groupUnreadCounts.value;

  @override
  void onInit() {
    super.onInit();

    searchTextController.addListener(() {
      if (searchTextController.text.isEmpty) {
        clearSearch();
      } else {
        applySearch();
      }
    });

    attachNotificationListener();
  }

  void changeTab(ConversationTabs tab) {
    if (currentTab.value == tab) return;
    searchTextController.clear();
    currentTab(tab);
  }

  bool isUserOnline(int? id, String? modelType) {
    return (onlineUsers.firstWhereOrNull(
            (element) => element.id == id && element.modelType == modelType) !=
        null);
  }

  attachNotificationListener() async {
    // Wait for the backgrounded post-login realtime setup (config + connect)
    // before subscribing — the client is null until then.
    await Get.find<AuthController>().realtimeReady;

    var messageNotificationChannel =
        await pusher.subscribeToMessageNotificationChannel();
    messageNotificationSubscription = messageNotificationChannel
        .bind("message-received")
        .listen((event) async {
      try {
        if (event.data != null) {
          final jsonData = jsonDecode(event.data);

          final int conversationId = jsonData['conversation_id'];

          // updating one to one conversations
          try {
            if (Get.isRegistered<OtoConversationsController>()) {
              Get.find<OtoConversationsController>().moveConversationOnTop(
                conversationId,
                ConversationLastMessageEntity.fromJson(jsonData['message']),
                incrementUnread: true,
              );
              final newMessage =
                  ConversationLastMessageEntity.fromJson(jsonData['message']);

              final messageEntity = ConversationMessageEntity(
                id: newMessage.id,
                message: newMessage.message,
                conversationId: conversationId,
                createdAt: newMessage.createdAt,
              );

              await messagesDb.insertMessage(messageEntity);
            }
          } catch (_) {}

          // updating in group conversations list
          try {
            //
            if (Get.isRegistered<GroupConversationsController>()) {
              Get.find<GroupConversationsController>()
                  .moveGroupConversationOnTop(
                conversationId,
                GroupMessageEntity.fromJson(jsonData['message']),
                incrementUnread: true,
              );
            }
          } catch (_) {}
        }
      } catch (_) {}
    });

    newConversationCreatedSubscription = messageNotificationChannel
        .bind("new-conversation-created")
        .listen((event) {
      try {
        if (event.data != null) {
          final jsonData = jsonDecode(event.data);

          if (jsonData["conversation"]["type"] == "group") {
            _getGroupConversationsController()?.getAllGroupConversations();
          } else {
            _getOtoConversationsController()?.getAllConversations();
          }
        }
      } catch (_) {}
    });

    //
    // online users channel
    final onlineUserChannel = await pusher.subscribeToOnlineChannel();

    // when subscription succeded handling already online user data
    onlineSubscriptionSucceededSubscription =
        onlineUserChannel.whenSubscriptionSucceeded().listen((event) {
      try {
        if (event.data != null) {
          final presenceData = presenceDataModelFromJson(event.data);
          onlineUsers.clear();
          if (presenceData.presence?.hash != null) {
            presenceData.presence!.hash!.forEach((key, value) {
              onlineUsers
                  .add(OnlineUser(id: value.id, modelType: value.modelType));
            });
          }
        }
      } catch (e) {
        debugPrint('[Online] subscriptionSucceeded parse error: $e');
      }
    });

    //lisner when new user added or join the socket
    onlineUserAddedSubscription =
        onlineUserChannel.whenMemberAdded().listen((event) {
      try {
        if (event.data != null) {
          final newUser = presenceUserAddedModelFromJson(event.data).user;
          if (newUser != null) {
            if (onlineUsers.firstWhereOrNull((element) =>
                    (element.id == newUser.id) &&
                    (element.modelType == newUser.modelType)) ==
                null) {
              onlineUsers.add(
                  OnlineUser(id: newUser.id, modelType: newUser.modelType));
            }
          }
        }
      } catch (e) {
        debugPrint('[Online] memberAdded parse error: $e');
      }
    });

    // listener when user is removed or disconnected
    onlineUserRemovedSubscription =
        onlineUserChannel.whenMemberRemoved().listen((event) {
      try {
        if (event.data != null) {
          final json = jsonDecode(event.data);
          if (json['user_id'] != null) {
            final removedUserId = json['user_id'];
            onlineUsers.removeWhere(
                (element) => element.id.toString() == removedUserId.toString());
          }
        }
      } catch (e) {
        debugPrint('[Online] memberRemoved parse error: $e');
      }
    });
  }

  // applting search in the bases of selected tab and add then to filtered list
  // search by firstname, lastname, name, phone
  void applySearch() {
    if (currentTab.value == ConversationTabs.chat) {
      _getOtoConversationsController()?.applySearch(searchTextController.text);
    } else if (currentTab.value == ConversationTabs.group) {
      _getGroupConversationsController()
          ?.applySearch(searchTextController.text);
    }
  }

  void clearSearch() {
    _getOtoConversationsController()?.clearSearch();
    _getGroupConversationsController()?.clearSearch();
  }

  OtoConversationsController? _getOtoConversationsController() {
    try {
      if (Get.isRegistered<OtoConversationsController>()) {
        return Get.find<OtoConversationsController>();
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  GroupConversationsController? _getGroupConversationsController() {
    try {
      if (Get.isRegistered<GroupConversationsController>()) {
        return Get.find<GroupConversationsController>();
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  //
  //
  //
  void updateOtoUnreadCounts() {
    _otoUnreadCounts.value = 0;

    //
    // getting unread counts from one to one conversation
    try {
      if (Get.isRegistered<OtoConversationsController>()) {
        _otoUnreadCounts.value =
            Get.find<OtoConversationsController>().otoUnreadCounts.value;
      }
    } catch (_) {}
  }

  //
  //
  //
  void updateGroupUnreadCounts() {
    _groupUnreadCounts.value = 0;

    //
    // getting unread counts from group conversation
    try {
      if (Get.isRegistered<GroupConversationsController>()) {
        _groupUnreadCounts.value =
            Get.find<GroupConversationsController>().groupUnreadCounts.value;
      }
    } catch (_) {}
  }

  @override
  void onClose() async {
    messageNotificationSubscription?.cancel();
    newConversationCreatedSubscription?.cancel();
    pusher.unsubscribeMessageNotificationChannel();

    super.onClose();
  }
}

enum ConversationTabs { chat, group }

class OnlineUser {
  int? id;
  String? modelType;
  OnlineUser({
    this.id,
    this.modelType,
  });
}
