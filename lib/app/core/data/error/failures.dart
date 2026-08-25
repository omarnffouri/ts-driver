import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String? title;
  final String message;
  final int? code;
  const Failure({required this.message, this.title, this.code});
  @override
  List<Object?> get props => [message, title];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    required String title,
    int? code,
  }) : super(
          message: message,
          title: title,
          code: code,
        );
}

class OfflineFailure extends Failure {
  const OfflineFailure({required super.message});
}

class EmptyCacheFailure extends Failure {
  const EmptyCacheFailure({required super.message});
}

class FirebaseFailure extends Failure {
  const FirebaseFailure({required super.message});
}

// add unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure({required super.message});
}

class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message: message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message: message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(String message) : super(message: message);
}
