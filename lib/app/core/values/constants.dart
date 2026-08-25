// ignore_for_file: constant_identifier_names

// server base url
import 'package:get_storage/get_storage.dart';

const String SERVER_FAILURE_MESSAGE = 'Please try again later .';
const String EMPTY_CACHE_FAILURE_MESSAGE = 'No Data';
const String OFFLINE_FAILURE_MESSAGE = 'Please Check your Internet Connection';

const String USER_DATA = "userData";
const String SSN = "userName";
const String MOBILE = "mobileNumber";
const String KB_HEIGHT = "kb_height";

const String REMEMBERME = "rememberMe";
const String TOKEN = "token";
const String REALTIME_CONFIGURATION = "realtime_configuration";
const String APPLICANT_ID = "applicant_id";
const String USER_ID = "user_id";
const String IS_AUTHENTICATED = "isAuthenticated";
const String DARK_MODE = "darkMode";
// theme mode: "system" | "light" | "dark" (replaces the legacy DARK_MODE bool)
const String THEME_MODE = "themeMode";
const String databaseName = 'app_database.db';
const String trucksTableName = 'truck_table';
const String isClockServiceRunning = 'isClockTrackServiceRunning';
const String isShipmentServiceRunning = 'isShipmentTrackServiceRunning';
const String currentTransit = 'currentTransit';
const String uuId = 'uuId';

// Google Maps / Directions API key. Also configured in the Android manifest and
// iOS AppDelegate; restricted by app signature/bundle id, so not a secret.
const String GOOGLE_MAPS_API_KEY = 'REPLACE_WITH_GOOGLE_API_KEY';

typedef MapBody = Map<String, dynamic>;

class CommonVariables {
  static GetStorage userData = GetStorage();
  static GetStorage settings = GetStorage();
  static GetStorage tracking = GetStorage();
}

class AuthenticationPrefKeys {
  static const String biometricSSN = "biometricSSN";
  static const String token = "token";
  static const String biometricMobile = "biometricMobile";
  static const String biometricEnabled = "biometricEnabled";
  static const String biometricReady = "biometricReady";
  static const String biometricPromptSeen = "biometricPromptSeen";
}

class AuthorizationTexts {
  static const String electronicSignature =
      'I hereby agree and consent to completing this application and background investigation process electronically. I understand that I will be signing this application and all forms related to this application electronically and that the electronic signatures appearing on these documents are the same as my handwritten signature for the purposes of validity, enforceability and admissibility.';

  static const String inquiryToPreviousEmployer =
      'Inquiry to Previous Employer';

  static const String drivingHistory =
      'Previous Employer Inquiry For Driving History & Safety Performance';

  static const String pspConsentForm = 'PSP Consent Form';

  static const String releaseOfInfo = 'Consent for Release of Info Form';

  static const String substanceConsent =
      'Pre-Employment Controlled Substance Consent Form';

  static const String driversRights =
      'Drivers Rights Pertaining to Release of Information under Regulation 391.23';
}
