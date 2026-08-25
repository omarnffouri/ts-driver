import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/values/constants.dart';
import 'package:ts_driver/app/modules/auth/domain/params/firebase_sign_in_params.dart';

abstract class IFirebaseRemoteDataSource {
  Future<Either<void, Failure>> signInToFirebase(FirebaseSignInParams params);
  Future<Either<void, Failure>> sendUserLocation(MapBody body);
}

class FirebaseRemoteDatasourceImpl extends IFirebaseRemoteDataSource {
  final FirebaseAuth _auth;
  final firestore = FirebaseFirestore.instance;

  FirebaseRemoteDatasourceImpl({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<Either<Unit, Failure>> signInToFirebase(
    FirebaseSignInParams params,
  ) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: params.email,
        password: params.ssn,
      );
      log('Firebase Auth: Signed in successfully');
      return const Left(unit);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return _createFirebaseUser(params);
      } else if (e.code == 'wrong-password') {
        log('Firebase Auth: Wrong password');
        return const Right(
            FirebaseFailure(message: 'Wrong password provided for that user.'));
      }
      log('Firebase Auth: Error - ${e.code}');
      return Right(FirebaseFailure(message: 'Firebase Auth error: ${e.code}'));
    } catch (e) {
      log('Firebase Auth: Unexpected error - $e');
      return const Right(FirebaseFailure(message: 'Error signing in'));
    }
  }

  Future<Either<Unit, Failure>> _createFirebaseUser(
    FirebaseSignInParams params,
  ) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: params.email,
        password: params.ssn,
      );
      log('Firebase Auth: Created new user and signed in');
      return const Left(unit);
    } catch (e) {
      log('Firebase Auth: Error creating user - $e');
      return Right(
          FirebaseFailure(message: 'Error creating Firebase user: $e'));
    }
  }

  @override
  Future<Either<Unit, Failure>> sendUserLocation(MapBody body) async {
    String timestampId =
        DateTime.now().toUtc().millisecondsSinceEpoch.toString();

    final String userId = body["user_id"].toString();
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final logsRef =
        firestore.collection("user_tracking").doc(today).collection(userId);

    try {
      await logsRef.doc(timestampId).set(body);
      return const Left(unit);
    } catch (error) {
      log(error.toString());
      return const Right(
          FirebaseFailure(message: 'Error sending user location'));
    }
  }
}
