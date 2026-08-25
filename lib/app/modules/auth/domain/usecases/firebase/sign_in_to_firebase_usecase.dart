import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/modules/auth/domain/entities/user_entity.dart';

import '../../params/firebase_sign_in_params.dart';
import '../../repositories/firebase_repository.dart';

class SignInToFirebaseUseCase extends BaseUseCase<void, FirebaseSignInParams> {
  final IFirebaseRepository _repository;

  SignInToFirebaseUseCase(this._repository);

  @override
  Future<Either<void, Failure>> call(FirebaseSignInParams params) async {
    return await _repository.signInToFirebase(params);
  }

  /// Fire-and-forget sign-in from a [UserEntity].
  /// Skips silently if credentials are missing.
  Future<void> fireAndForget(UserEntity userEntity) {
    final email = userEntity.personalDetails?.email;
    final ssn = userEntity.personalDetails?.ssNo;
    if (email == null || email.isEmpty || ssn == null || ssn.isEmpty) {
      debugPrint('Firebase Auth skipped: missing email or SSN');
      return Future.value();
    }
    final params = FirebaseSignInParams(email: email, ssn: ssn);
    return call(params).then((_) {}).catchError((e) {
      debugPrint('Firebase Auth failed: $e');
    });
  }
}
