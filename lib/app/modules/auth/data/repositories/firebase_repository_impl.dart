import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/connection/network_info.dart';
import 'package:ts_driver/app/core/data/error/exceptions.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/values/constants.dart';
import 'package:ts_driver/app/core/services/injection_service.dart';

import '../../domain/params/firebase_sign_in_params.dart';
import '../../domain/repositories/firebase_repository.dart';
import '../datasources/firebase_remote_datasource.dart';

class FirebaseRepositoryImpl extends IFirebaseRepository {
  final NetworkInfoImpl networkInfo =
      NetworkInfoImpl(dataConnectionChecker: sl());
  final IFirebaseRemoteDataSource firebaseRemoteDataSource;
  FirebaseRepositoryImpl({required this.firebaseRemoteDataSource});

  Future<Either<void, Failure>> _withNetworkCheck(
    Future<Either<void, Failure>> Function() action,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        return await action();
      } on ServerException catch (e) {
        return Right(ServerFailure(title: '', message: e.message));
      }
    }
    return const Right(
      OfflineFailure(message: 'No Internet, try again later'),
    );
  }

  @override
  Future<Either<void, Failure>> signInToFirebase(FirebaseSignInParams params) =>
      _withNetworkCheck(
          () => firebaseRemoteDataSource.signInToFirebase(params));

  @override
  Future<Either<void, Failure>> sendUserLocation(MapBody body) =>
      _withNetworkCheck(() => firebaseRemoteDataSource.sendUserLocation(body));
}
