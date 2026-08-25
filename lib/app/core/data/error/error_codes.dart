/// ErrorCodes contains the string constants used to represent the
/// various error codes returned by Firebase Authentication.
///
/// These error codes are used to identify the type of error that occurred
/// during an authentication attempt. Each error code corresponds to an
/// error condition that is documented in the Firebase Authentication API.
class ErrorCodes {
  /// The password provided is too weak.
  static const String weakPassword = "weak-password";

  /// There already exists an account with the email address asserted by the credential.
  static const String existAccount = "account-exists-with-different-credential";

  /// There is no user record corresponding to this identifier.
  static const String userNotFound = "user-not-found";

  /// The password is invalid or the user does not have a password.
  static const String wrongPassword = "wrong-password";

  /// The email address is not valid.
  static const String invalidEmail = "invalid-email";

  /// There have been too many requests in a short period of time.
  static const String tooManyRequests = "too-many-requests";

  /// The administrator has disabled the operation you're trying to perform.
  static const String operationNotAllowed = "operation-not-allowed";

  /// The user corresponding to the provided email has been disabled.
  static const String userDisabled = "user_disabled";

  /// The email address is already in use by another account.
  static const String emailIsUsed = "email-already-in-use";

  /// The verification code used to create the phone auth credential is invalid.
  static const String invalidVerificationCode = "invalid-verification-code";

  /// The verification ID used to create the phone auth credential is invalid.
  static const String invalidVerificationId = "invalid-verification-id";

  /// An unexpected error occurred. This is a fallback for all other errors.
  static const String unexpectedError = "unexpected_error";

  /// The network request failed due to a connectivity issue.
  static const String networkConnectionFailed = "network-request-failed";
}
