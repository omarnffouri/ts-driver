import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';

import 'error_codes.dart';
import 'error_messages.dart';
import 'exceptions.dart';

class ErrorHandler {
  late final Failure failure;

  ErrorHandler.handle(dynamic error) {
    if (error is FirebaseAuthException) {
      failure = _handleError(error);
    } else if (error is OfflineException) {
      failure =
          const OfflineFailure(message: ErrorMessages.networkConnectionFailed);
    } else if (error is SocketException) {
      failure =
          const OfflineFailure(message: ErrorMessages.networkConnectionFailed);
    } else if (error is EmptyCacheException) {
      failure = const EmptyCacheFailure(message: ErrorMessages.emptyCache);
    } else {
      failure = const UnknownFailure(message: ErrorMessages.unexpectedError);
    }
  }
}

Failure _handleError(FirebaseAuthException authException) {
  switch (authException.code) {
    case ErrorCodes.existAccount:
    case ErrorCodes.emailIsUsed:
      return const FirebaseFailure(message: ErrorMessages.existAccount);
    case ErrorCodes.weakPassword:
      return const FirebaseFailure(message: ErrorMessages.weakPassword);
    case ErrorCodes.invalidEmail:
      return const FirebaseFailure(message: ErrorMessages.invalidEmail);
    case ErrorCodes.operationNotAllowed:
      return const FirebaseFailure(message: ErrorMessages.operationNotAllowed);
    case ErrorCodes.tooManyRequests:
      return const FirebaseFailure(message: ErrorMessages.tooManyRequests);
    case ErrorCodes.userDisabled:
      return const FirebaseFailure(message: ErrorMessages.userDisabled);
    case ErrorCodes.userNotFound:
      return const FirebaseFailure(message: ErrorMessages.userNotFound);
    case ErrorCodes.wrongPassword:
      return const FirebaseFailure(message: ErrorMessages.wrongPassword);
    case ErrorCodes.invalidVerificationCode:
      return const FirebaseFailure(
        message: ErrorMessages.invalidVerificationCode,
      );
    case ErrorCodes.invalidVerificationId:
      return const FirebaseFailure(
        message: ErrorMessages.invalidVerificationId,
      );
    case ErrorCodes.networkConnectionFailed:
      return const FirebaseFailure(
        message: ErrorMessages.networkConnectionFailed,
      );
    default:
      return const FirebaseFailure(message: ErrorMessages.unexpectedError);
  }
}
