import 'package:get/get.dart';
import 'package:ts_driver/app/modules/chat_detail/data/models/call_notification_payload_model.dart';
import 'package:ts_driver/app/native_calling/channels/native_calling_event_channel.dart';
import 'package:ts_driver/app/native_calling/enums/native_calling_events.dart';
import 'package:ts_driver/app/native_calling/models/native_calling_event.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';

class CallEventsController extends GetxController {
  final Rxn<CallNotificationPayloadModel> currentCall = Rxn();
  final RxBool isCalling = false.obs;
  final RxInt callHours = 0.obs;
  final RxInt callMinutes = 0.obs;
  final RxInt callSeconds = 0.obs;
  final RxnString receiverName = RxnString();
  final RxnString receiverImage = RxnString();

  @override
  void onInit() {
    super.onInit();
    _listenForCallEvents();
  }

  void _listenForCallEvents() {
    NativeCallingEventChannel.onEvent.listen((NativeCallingEvent? event) {
      if (event == null) {
        return;
      }
      switch (event.event) {
        case NativeCallingEvents.callReceived:
          //
          // parse event data to call notification payload model
          final payload = getCallPayloadFromEventData(event.data);
          if (payload == null) {
            return;
          }

          callHours.value = 0;
          callMinutes.value = 0;
          callSeconds.value = 0;
          currentCall.value = payload;
          isCalling.value = false;
          receiverName.value = null;
          receiverImage.value = null;
          break;

        case NativeCallingEvents.callTime:

          // Create a new Map<String, dynamic>
          Map<String, dynamic> convertedMap = {};

          // Copy values from the original map to the new map
          event.data.forEach((key, value) {
            convertedMap[key.toString()] = value.toString();
          });

          callHours.value = _parseIntFromDynamic(convertedMap["hours"]);
          callMinutes.value = _parseIntFromDynamic(convertedMap["minutes"]);
          callSeconds.value = _parseIntFromDynamic(convertedMap["seconds"]);
          isCalling.value = false;
          break;

        case NativeCallingEvents.callPlaced:
          //
          // parse event data to call notification payload model
          final payload = getCallPayloadFromEventData(event.data);
          if (payload == null) {
            return;
          }
          isCalling.value = true;
          receiverName.value = payload.receiverName;
          receiverImage.value = payload.receiverImage;
          currentCall.value = payload;
          break;

        case NativeCallingEvents.callEnded:
          endIOSCall(getCallPayloadFromEventData(event.data));
          break;

        case NativeCallingEvents.callDeclined:
          endIOSCall(getCallPayloadFromEventData(event.data));
          CommonWidgets.showSnackBar(
            title: "Call Declined",
            message: "",
            isError: false,
          );
          break;

        case NativeCallingEvents.callNoAnswer:
          endIOSCall(getCallPayloadFromEventData(event.data));
          CommonWidgets.showSnackBar(
            title: "Call Not Answered",
            message: "",
            isError: false,
          );
          break;

        case NativeCallingEvents.callUserBusy:
          endIOSCall(getCallPayloadFromEventData(event.data));
          CommonWidgets.showSnackBar(
            title: "Busy",
            message: "The person you called is busy on another call.",
            isError: false,
          );
          break;
        case NativeCallingEvents.callFailed:
          endIOSCall(getCallPayloadFromEventData(event.data));
          CommonWidgets.showSnackBar(
            title: "Call Failed",
            message: "Failed to connect call.",
            isError: false,
          );
          break;
      }
    });
  }

  //
  //
  /// function to end ios call and reset the variable states
  void endIOSCall(CallNotificationPayloadModel? payload) {
    if (payload == null) {
      return;
    }

    if (payload.tempCallId != null &&
        payload.tempCallId == currentCall.value?.tempCallId) {
      callHours.value = 0;
      callMinutes.value = 0;
      callSeconds.value = 0;
      currentCall.value = null;
      isCalling.value = false;
      receiverName.value = null;
      receiverImage.value = null;
    }
  }

  //
  //
  /// function to get caller or receiver names first letter
  String getCallerNameFirstLetter() {
    if (receiverName.value != null) {
      if (receiverName.value!.isNotEmpty) {
        return receiverName.value![0].capitalize ?? "";
      }
    } else if (currentCall.value?.callerName != null) {
      if (currentCall.value!.callerName!.isNotEmpty) {
        return currentCall.value!.callerName![0].capitalize ?? "";
      }
    }
    return "";
  }

  //
  //
  /// function that parse the event data to json
  /// and then make call payload model from that parsed json
  CallNotificationPayloadModel? getCallPayloadFromEventData(dynamic data) {
    // Create a new Map<String, dynamic>
    Map<String, dynamic> convertedMap = {};

    // Copy values from the original map to the new map
    data.forEach((key, value) {
      convertedMap[key.toString()] = value.toString();
    });

    final payload = CallNotificationPayloadModel.fromJson(convertedMap);
    if (payload.callType == null) {
      return null;
    }
    return payload;
  }

  int _parseIntFromDynamic(dynamic data) {
    if (data == null) {
      return 0;
    }
    try {
      return int.parse(data.toString());
    } catch (_) {
      return 0;
    }
  }
}
