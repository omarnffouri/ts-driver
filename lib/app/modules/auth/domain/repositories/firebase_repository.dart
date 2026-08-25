import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/values/constants.dart';

import '../params/firebase_sign_in_params.dart';

abstract class IFirebaseRepository {
  Future<Either<void, Failure>> signInToFirebase(FirebaseSignInParams params);
  Future<Either<void, Failure>> sendUserLocation(MapBody body);
}
