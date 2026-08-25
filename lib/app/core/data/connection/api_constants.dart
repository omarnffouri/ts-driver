import '../../values/constants.dart';
import 'environments.dart';

class ApiConstants {
  ApiConstants._();

  // Environment follows the build flavor (`flutter run --flavor dev|staging|prod`).
  static Environment get _env => Environment.current;
  static final String kServerURL = 'https://${_env.host}/api/v2/';

  static bool get isDev => _env == Environment.dev;
  static bool get isStaging => _env == Environment.staging;
  static bool get isProduction => _env == Environment.production;

  static final String host = _env.host;

  // Realtime config is cached per-environment so a snapshot written by one
  // environment (e.g. staging) can never be served to another (e.g. dev).
  static String get realtimeConfigKey => '${REALTIME_CONFIGURATION}_$host';

  //! auth
  static const String login = "drivers/login";
  static const String logout = "drivers/logout";
  static const String register = "drivers/application/submit";
  static const String updateProfile = "drivers/update-profile";
  static const String fetchExistingUser = "drivers/check-account";
  static const String checkEmailVerification =
      "drivers/check-email-verification";
  static const String deleteAccount = "drivers/delete";
  static const String profile = "drivers/profile";
  static const String updateFcmToken = "drivers/update/fcm-token";
  static const String updateVoip = "voip/update";
  static const String realtimeConfiguration = "drivers/realtime-configuration";

  //! documents
  static const String getDocuments = "drivers/document-requests";
  static const String uploadDocument = "drivers/document-requests/upload";

  //! forms
  static const String getForms = "drivers/forms";
  static const String signForm = "drivers/sign-form";
  static const String updateFormAttachmentStatus =
      "drivers/forms/update/status/video-attachment";
  static const String getSignedForm = "drivers/get-signed-form";

  //! videos
  static const String getVideos = "drivers/videos";
  static const String updateVideo = "drivers/update-video";

  //! notifications
  static const String getNotifications = "notifications/get-notifications";
  static const String updateNotification = "notifications/update-notification";

  //! shipments
  static const String getShipments = "shipments/get-all-shipments";
  static const String getShipmentDetails = "shipments/get-shipment-detail";
  static const String updateShipment = "shipments/update-shipment";
  static const String completeShipment = "shipments/complete-shipment";
  static const String stopReached = "shipments/stop-reached";

  //! inspection
  static const String getInspectionOptions =
      "inspection/categories-and-truck-parts";
  static const String createInspection = "inspection/create";

  //! OTHER
  static const String getCities = "base/get-cities";
  static const String getAppConfiguration = "drivers/get-app-configuration";

  //! Home
  static const String applicantState = "drivers/status";
  static const String checkClockIn = "driver/check-clock";
  static const String clockIn = "admin/clockin";
  static const String clockOut = "admin/clockout";
  static const String weekDeatils = "driver/timesheet-for-week";

  //! chat
  static const String getContacts = "chat/contacts";
  static const String getConversations = "chat/conversations";
  static const String getGroupConversations = "chat/groups";
  static const String createConversation = "chat/conversation/create";
  static const String getConversationDetails = "chat/conversation";
  static const String postMessage = "chat/conversation/store";
  static const String forwardMessage = "chat/conversation/message/forward";
  static const String reactMessage = "chat/conversation/react/";
  static const String deleteMessage = "chat/conversation/message";
  static const String markMessageAsRead = "chat/conversation/message/read";

  //! truck documents
  static const String getTruckDocuments = "truck/documents";
  static const String checkTruckDocuments = "truck/has-documents";

  //! settelments
  static const String getSettelments = "driver/settlement";
  static const String getSettelmentDetails = "driver/settlement";
  static const String getTrailerDocuments = "trailer/documents";

  //! calling
  static const String callEvent = "chat/agora/call";
  static const String getAgoraToken = "chat/agora/token";
  static const String startCallRecording = "chat/agora/startCallRecording";
  static const String stopCallRecording = "chat/agora/stopCallRecording";

  //! Verify
  static const String sendOtp = "otp/send";
  static const String verify = "otp/verify";
  static const String verifyRegisterOtp = "otp/verify-otp-code";
  static const String isEnabled = "otp/is-enabled";
  static const String checkVerification = "otp/check-verification";

  //! leave management
  // new request
  static const String getLeaveTypes = "usermanagement/leave/types";
  static const String getSupervisors = "usermanagement/supervisor";
  static const String checkEligibility = "usermanagement/leave/eligibility";
  static const String submitLeaveRequest = "usermanagement/leave/submit";

  // leave requested
  static const String getRequestedLeaves = "usermanagement/leave/requests";

  // manage leave
  static const String getUsersLeaves = "usermanagement/leave/management";
  static const String adminAction = "usermanagement/leave/action";

  // leave history
  static const String getLeaveHistory = "usermanagement/leave/history";

  //! partner settlements
  static const String getPartnerSettlements = "driver/partner/settlements";
  static const String getPartnerSettlementDetails = "driver/partner/settlement";
  static const String getPartnerDrivers = "driver/get-partner-drivers";
  static const String updateDriverPermission =
      "driver/partner-drivers/update-status";

  //! annoucements endpoints
  static const String getAllAnnoucements = "notifications/get-announcements";
  static const String updateAccoucementReadStatus =
      "notifications/mark-announcements-as-read";
}
