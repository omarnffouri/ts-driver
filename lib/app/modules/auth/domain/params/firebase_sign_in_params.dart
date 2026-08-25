import 'package:equatable/equatable.dart';

/// Parameters for Firebase authentication.
/// Uses [email] as the Firebase email and [ssn] as the Firebase password.
class FirebaseSignInParams extends Equatable {
  final String email;
  final String ssn;

  const FirebaseSignInParams({
    required this.email,
    required this.ssn,
  });

  @override
  List<Object?> get props => [email, ssn];
}
