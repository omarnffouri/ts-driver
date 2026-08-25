import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/modules/annoucments/presentation/controllers/annoucments_controller.dart';
import 'package:ts_driver/app/modules/chat/domain/params/buzz_message_params.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';
import 'package:ts_driver/app/modules/shipments/presentation/controllers/shipments_controller.dart';

import '../../modules/home/presentation/controllers/home_controller.dart';
import '../../modules/notifications/presentation/controllers/notifications_controller.dart';
import '../../routes/app_pages.dart';

class LocalNotification {
  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  /// Create a [AndroidNotificationChannel] for heads up notifications
  static late AndroidNotificationChannel channel;
  static bool isFlutterLocalNotificationsInitialized = false;

  static Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: android, iOS: iOS);

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: notificationTap,
    );

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.initialize(const DarwinInitializationSettings());

    //

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    isFlutterLocalNotificationsInitialized = true;
  }

  static void showFlutterNotification(RemoteMessage message) async {
    // Call pushes are owned by the native layer (Telecom ring, missed-call);
    // rendering them here duplicates the call UI.
    if (message.data['notification_type'] == 'call') return;
    await Get.put(NotificationsController()).getAllNotifications();
    RemoteNotification? notification = message.notification;
    final body = message.data;
    final type = body['notification_type'];

    if (type == "applicant_status_change") {
      await Get.put(HomeController()).init();
    }
    if (type.contains("ship")) {
      if (Get.isRegistered<ShipmentsController>()) {
        Get.find<ShipmentsController>().refreshAll();
      }
    }

    if (type == "web") {
      try {
        if (Get.isRegistered<AnnoucmentsController>(tag: "home")) {
          final announcementsController =
              Get.find<AnnoucmentsController>(tag: "home");
          announcementsController.getAllAnnoucements();
        }
      } catch (_) {}
    }

    BigPictureStyleInformation? bigPic;
    if (type != "chat") {
      // check if body of image is not empty
      final img = body['image'];
      if ((img ?? "").isNotEmpty) {
        bigPic = await fetchData(img);
      }
    }

    String? notificationMessage;

    //
    // fetch the message of the notification
    try {
      notificationMessage = type == "chat"
          ? body['message']
          : type == "web"
              ? removeAllHtmlTags(body['message'] ?? "")
              : body['body'];
    } catch (_) {}

    //
    // if notification type is chat then check if message string in notification is empty
    // then consider notification as media message notification
    // and also check if notification belogs to the currenly active/opened chat then return/ignore
    if (type == "chat") {
      try {
        if ((body['message'] as String).isEmpty) {
          notificationMessage = "media 📎";
        }
      } catch (_) {}

      try {
        if (Get.isRegistered<ChatDetailController>()) {
          final chatDetailController = Get.find<ChatDetailController>();
          if (body['conversationId']?.toString() ==
              chatDetailController.conversationId.toString()) {
            final haveBuzz =
                (body['title'] ?? "").toString().toLowerCase().contains("buzz");

            if (haveBuzz) {
              final converstionId = chatDetailController.conversationId;
              final messageId = (body['messageId'] != null)
                  ? int.parse(body['messageId'].toString())
                  : null;
              chatDetailController.onBuzzReceived(
                BuzzMessageParams(
                  converstionId: converstionId,
                  messageId: messageId,
                ),
              );
            }

            return;
          }
        }
      } catch (_) {}
    }

    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb && body.isNotEmpty) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        body['title'],
        notificationMessage,
        payload: json.encode(message.data),
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            priority: Priority.high,
            importance: Importance.max,
            // largeIcon: ,
            styleInformation: bigPic,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    }
  }

  static String removeAllHtmlTags(String htmlText) {
    RegExp exp =
        RegExp(r'<[^>]*>|&[^;]+;', multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '').replaceAll('Html', '');
  }

  static notificationTap(NotificationResponse notificationResponse) {
    if (notificationResponse.payload == null) return;
    final Map<String, dynamic> data =
        json.decode(notificationResponse.payload!);
    if (data.containsKey('notification_type')) {
      handleMessage(data);
    }
    debugPrint('notification(${notificationResponse.id}) action tapped: '
        '${notificationResponse.actionId} with'
        ' payload: ${notificationResponse.payload}');
  }

  static handleMessage(Map<String, dynamic> data) async {
    final type = data['notification_type']; //todo check this with backend
    //switch case for each type of notification
    switch (type) {
      case "forms":
        Get.toNamed(Routes.FORMS, arguments: true);
        break;
      case "applicant_status_change":
        await Get.put(HomeController()).init();
        break;
      case "videos":
        Get.toNamed(Routes.VIDEOS, arguments: true);
        break;
      case "chat" || "group":
        // add the body of the notification to the chat
        Map<String, dynamic> body = getBody(data);
        if (Get.isRegistered<ChatDetailController>()) {
          Get.until((route) => route.settings.name == Routes.MAIN_SCREEN);

          // Get.find<ChatDetailController>();

          Future.delayed(const Duration(milliseconds: 1500), () {
            Get.toNamed(
              Routes.CHAT_DETAIL,
              arguments: body,
            );
          });
        } else {
          Get.toNamed(Routes.CHAT_DETAIL, arguments: body);
        }
        break;
      case "driver_license" ||
            "medical_card" ||
            "social_security" ||
            "ss_4" ||
            "upload":
        Get.toNamed(Routes.DOCUMENTS, arguments: true);
        break;

      default:
    }
  }

  static Map<String, dynamic> getBody(Map<String, dynamic> data) {
    final haveBuzz =
        (data['title'] ?? "").toString().toLowerCase().contains("buzz");

    // add the body of the notification to the chat
    final body = {
      "userId": int.parse(data['sender_model_id'].toString()),
      "userName": data['conversationType'] == "group"
          ? data['conversationName']
          : data['sender_name'],
      "userImage": data['sender_image'],
      "userPhone": data['sender_phone'],
      "type": data['conversationType'],
      "chatable": data['chatable'] == true ||
          data['chatable'].toString().toLowerCase() == "true",
      "conversation_id": int.parse(data['conversationId'].toString()),
      "modelType": data['sender_model_type'],
      "is_from_notification": true,
      "haveBuzz": haveBuzz,
      "buzzOnMessage": ((data['messageId'] != null) && haveBuzz)
          ? int.parse(data['messageId'].toString())
          : null,
    };
    return body;
  }

  static Future<BigPictureStyleInformation?> fetchData(String img) async {
    try {
      final http.Response response = await http.get(Uri.parse(img));
      BigPictureStyleInformation bigPictureStyleInformation =
          BigPictureStyleInformation(
        ByteArrayAndroidBitmap.fromBase64String(
          base64Encode(response.bodyBytes),
        ),
        largeIcon: ByteArrayAndroidBitmap.fromBase64String(
          base64Encode(response.bodyBytes),
        ),
      );
      return bigPictureStyleInformation;
    } catch (_) {}

    return null;
  }
}
