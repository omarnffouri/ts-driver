enum AgoraCallEvents {
  incomingCall,
  incomingCallDeclined,
  callAccepted,
  callDeclined,
  callEnded,
  userBusy,
  callRinging,
  noAnswer,
}

extension AgoraCallEventExtension on AgoraCallEvents {
  String get value {
    switch (this) {
      case AgoraCallEvents.incomingCall:
        return 'incomming-call';
      case AgoraCallEvents.incomingCallDeclined:
        return 'incomming-call-declined';
      case AgoraCallEvents.callAccepted:
        return 'call-accepted';
      case AgoraCallEvents.callDeclined:
        return 'call-declined';
      case AgoraCallEvents.callEnded:
        return 'call-ended';
      case AgoraCallEvents.userBusy:
        return 'user-bueasy'; // preserved typo if intentional
      case AgoraCallEvents.callRinging:
        return 'call-ringing';
      case AgoraCallEvents.noAnswer:
        return 'no-answer';
    }
  }

  static AgoraCallEvents? fromValue(String value) {
    switch (value) {
      case 'incomming-call':
        return AgoraCallEvents.incomingCall;
      case 'incomming-call-declined':
        return AgoraCallEvents.incomingCallDeclined;
      case 'call-accepted':
        return AgoraCallEvents.callAccepted;
      case 'call-declined':
        return AgoraCallEvents.callDeclined;
      case 'call-ended':
        return AgoraCallEvents.callEnded;
      case 'user-bueasy':
        return AgoraCallEvents.userBusy;
      case 'call-ringing':
        return AgoraCallEvents.callRinging;
      case 'no-answer':
        return AgoraCallEvents.noAnswer;
      default:
        return null;
    }
  }
}
