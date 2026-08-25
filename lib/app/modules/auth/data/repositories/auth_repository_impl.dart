import 'package:flutter/foundation.dart';
import 'package:ts_driver/app/core/data/connection/network_info.dart';
import 'package:ts_driver/app/core/helpers/functions.dart';
import 'package:ts_driver/app/modules/auth/data/models/user_model.dart';
import 'package:ts_driver/app/modules/auth/domain/entities/app_configration_entity.dart';
import 'package:ts_driver/app/core/services/injection_service.dart';

import 'package:ts_driver/app/core/data/error/failures.dart';

import 'package:dartz/dartz.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/entities/realtime_configuration_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_model.dart';
import '../models/region_model.dart';

typedef Body = Map<String, dynamic>;

class AuthRepositoryImpl extends IAuthRepository {
  NetworkInfoImpl networkInfo = NetworkInfoImpl(dataConnectionChecker: sl());
  final IAuthRemoteDataSource authRemoteDatasource;
  final IAuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.authRemoteDatasource,
    required this.localDataSource,
  });
  @override
  Future<Either<UserModel, Failure>> login(Body body) async {
    if (await networkInfo.isConnected) {
      final result = await executeAndHandleError(
        () => authRemoteDatasource.login(body),
      );

      return result.fold(
        (userModel) async {
          try {
            final authModel = AuthModel.fromUserModel(userModel);
            await localDataSource.cacheAuthData(authModel);
            debugPrint('✅ Login successful - Auth data cached');
            return Left(userModel);
          } catch (e) {
            debugPrint('⚠️ Login successful but caching failed: $e');
            return Left(userModel);
          }
        },
        (failure) => Right(failure),
      );
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }

  @override
  Future<Either<UserModel, Failure>> register(Body body) async {
    if (await networkInfo.isConnected) {
      final result = await executeAndHandleError(
        () => authRemoteDatasource.register(body),
      );

      return result.fold(
        (userModel) async {
          try {
            final authModel = AuthModel.fromUserModel(userModel);
            await localDataSource.cacheAuthData(authModel);
            debugPrint('✅ Registration successful - Auth data cached');
            return Left(userModel);
          } catch (e) {
            debugPrint('⚠️ Registration successful but caching failed: $e');
            return Left(userModel);
          }
        },
        (failure) => Right(failure),
      );
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }

  @override
  Future<Either<UserModel, Failure>> updateProfile(Body body) async {
    if (await networkInfo.isConnected) {
      return executeAndHandleError(
          () => authRemoteDatasource.updateProfile(body));
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }

  @override
  Future<Either<UserEntity, Failure>> fetchExistingProfile(Body body) async {
    if (await networkInfo.isConnected) {
      return executeAndHandleError(
        () => authRemoteDatasource.fetchExistingProfile(body),
      );
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }

  @override
  Future<Either<bool, Failure>> checkEmailVerification(Body body) async {
    if (await networkInfo.isConnected) {
      return executeAndHandleError(
        () => authRemoteDatasource.checkEmailVerification(body),
      );
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }

  @override
  Future<Either<bool, Failure>> deleteAccount() async {
    if (await networkInfo.isConnected) {
      return executeAndHandleError(() => authRemoteDatasource.deleteAccount());
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }

  @override
  Future<Either<bool, Failure>> logout() async {
    // try {
    //   await localDataSource.clearCachedAuthData();
    //   debugPrint('✅ Local auth data cleared');
    // } catch (e) {
    //   debugPrint('⚠️ Error clearing local cache: $e');
    // }

    if (await networkInfo.isConnected) {
      return executeAndHandleError(() => authRemoteDatasource.logout());
    } else {
      debugPrint('📱 Offline - Logout completed locally');
      return const Left(true);
    }
  }

  @override
  Future<Either<bool, Failure>> updateFCM(Body body) async {
    if (await networkInfo.isConnected) {
      return executeAndHandleError(() => authRemoteDatasource.updateFCM(body));
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }

  @override
  Future<Either<UserModel, Failure>> getProfile() async {
    try {
      if (!await localDataSource.hasValidToken()) {
        debugPrint('❌ No valid authentication found');
        return const Right(AuthFailure('No valid authentication found'));
      }

      final result = await executeAndHandleError(
        () => authRemoteDatasource.getProfile(),
      );

      return result.fold(
        (userModel) async {
          try {
            final cachedAuth = await localDataSource.getCachedAuthData();
            if (cachedAuth != null) {
              final updatedAuth = cachedAuth.copyWith(
                user: userModel,
                lastSyncedAt: DateTime.now(),
              );
              await localDataSource.cacheAuthData(updatedAuth);
              debugPrint('✅ Profile fetched - Cache updated with fresh data');
            } else {
              await localDataSource.updateCachedUser(userModel);
              debugPrint('✅ Profile fetched - User cache updated');
            }
          } catch (e) {
            debugPrint('⚠️ Profile fetched but cache update failed: $e');
          }
          return Left(userModel);
        },
        (failure) async {
          if (failure is OfflineFailure || failure is NetworkFailure) {
            debugPrint('📡 Network error - Attempting to use cached data');
            try {
              final cachedUser = await localDataSource.getCachedUser();
              if (cachedUser != null) {
                debugPrint('✅ Returning cached user profile');
                return Left(cachedUser);
              }
            } catch (e) {
              debugPrint('❌ Error getting cached user: $e');
            }
          }

          if (failure is AuthFailure || failure is ServerFailure) {
            if (failure.code == 401) {
              debugPrint('🔒 Unauthorized - Clearing cached auth data');
              try {
                await localDataSource.clearCachedAuthData();
              } catch (e) {
                debugPrint('⚠️ Error clearing cache: $e');
              }
            }
          }

          return Right(failure);
        },
      );
    } catch (e) {
      debugPrint('❌ Unexpected error in getProfile: $e');
      return const Right(UnexpectedFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<bool, Failure>> sendOtp(Body body) async {
    if (await networkInfo.isConnected) {
      return executeAndHandleError(() => authRemoteDatasource.sendOtp(body));
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }

  @override
  Future<Either<UserModel, Failure>> verifyOtp(Body body) async {
    if (await networkInfo.isConnected) {
      final result = await executeAndHandleError(
        () => authRemoteDatasource.verifyOtp(body),
      );

      return result.fold(
        (userModel) async {
          try {
            final authModel = AuthModel.fromUserModel(userModel);
            await localDataSource.cacheAuthData(authModel);
            debugPrint('✅ OTP verified - Auth data cached');
            return Left(userModel);
          } catch (e) {
            debugPrint('⚠️ OTP verified but caching failed: $e');
            return Left(userModel);
          }
        },
        (failure) => Right(failure),
      );
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }

  @override
  Future<Either<bool, Failure>> verifyRegisterOtp(Body body) async {
    if (await networkInfo.isConnected) {
      return executeAndHandleError(
          () => authRemoteDatasource.verifyRegisterOtp(body));
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }

  @override
  Future<Either<List<RegionModel>, Failure>> getCities(Body body) async {
    if (await networkInfo.isConnected) {
      return executeAndHandleError(() => authRemoteDatasource.getCities(body));
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }

  @override
  Future<Either<AppConfiguration, Failure>> getAppConfigration() async {
    if (await networkInfo.isConnected) {
      return executeAndHandleError(
          () => authRemoteDatasource.getAppConfigration());
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }

  @override
  Future<Either<RealtimeConfiguration, Failure>>
      getRealtimeConfiguration() async {
    if (await networkInfo.isConnected) {
      return executeAndHandleError(
          () => authRemoteDatasource.getRealtimeConfiguration());
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }
}
