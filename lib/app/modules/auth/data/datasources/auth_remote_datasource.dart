import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/connection/api_constants.dart';
import 'package:ts_driver/app/core/data/connection/dio_client.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/enum/http_request_type.dart';
import '../models/app_configration_model.dart';
import '../models/region_model.dart';
import '../models/realtime_configuration_model.dart';
import '../models/user_model.dart';

typedef Body = Map<String, dynamic>;

abstract class IAuthRemoteDataSource {
  Future<Either<UserModel, Failure>> login(Body body);
  Future<Either<bool, Failure>> logout();
  Future<Either<UserModel, Failure>> register(Body body);
  Future<Either<UserModel, Failure>> updateProfile(Body body);
  Future<Either<UserModel, Failure>> fetchExistingProfile(Body body);
  Future<Either<bool, Failure>> checkEmailVerification(Body body);
  Future<Either<bool, Failure>> deleteAccount();
  Future<Either<UserModel, Failure>> getProfile();
  Future<Either<bool, Failure>> updateFCM(Body body);
  Future<Either<bool, Failure>> sendOtp(Body body);
  Future<Either<UserModel, Failure>> verifyOtp(Body body);
  Future<Either<bool, Failure>> verifyRegisterOtp(Body body);
  Future<Either<List<RegionModel>, Failure>> getCities(Body body);
  Future<Either<AppConfigurationModel, Failure>> getAppConfigration();
  Future<Either<RealtimeConfigurationModel, Failure>>
      getRealtimeConfiguration();
}

class AuthRemoteDatasourceImpl implements IAuthRemoteDataSource {
  final DioClient client;
  AuthRemoteDatasourceImpl({required this.client});

  @override
  Future<Either<UserModel, Failure>> login(
      Map<String, dynamic> loginParams) async {
    try {
      final response = await client.makeRequest(
        method: RequestType.POST,
        url: ApiConstants.login,
        data: loginParams,
        converter: (response) {
          try {
            return UserModel.fromJson(
                response['data']['data'] as Map<String, dynamic>);
          } catch (e) {
            throw Exception(e);
          }
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<UserModel, Failure>> register(
      Map<String, dynamic> registerParams) async {
    try {
      final response = await client.makeRequest(
        method: RequestType.POST,
        url: ApiConstants.register,
        data: registerParams,
        converter: (response) {
          try {
            return UserModel.fromJson(
                response['data']['data'] as Map<String, dynamic>);
          } catch (e) {
            throw Exception(e);
          }
        },
      );
      return response;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Either<UserModel, Failure>> updateProfile(
      Map<String, dynamic> updateParams) async {
    try {
      final response = await client.makeRequest(
        method: RequestType.PUT,
        url: ApiConstants.updateProfile,
        data: updateParams,
        converter: (response) {
          try {
            return UserModel.fromJson(
                response['data']['data'] as Map<String, dynamic>);
          } catch (e) {
            throw Exception(e);
          }
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<UserModel, Failure>> fetchExistingProfile(
      Map<String, dynamic> body) async {
    try {
      final response = await client.makeRequest(
          method: RequestType.POST,
          url: ApiConstants.fetchExistingUser,
          data: body,
          converter: (response) {
            try {
              return UserModel.fromJson(
                  response['data']['data'] as Map<String, dynamic>);
            } catch (e) {
              throw Exception(e);
            }
          });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<bool, Failure>> checkEmailVerification(
      Map<String, dynamic> body) async {
    try {
      final response = await client.makeRequest(
          method: RequestType.POST,
          url: ApiConstants.checkEmailVerification,
          data: body,
          converter: (response) {
            try {
              return response['code'] == 200;
            } catch (e) {
              throw Exception(e);
            }
          });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<bool, Failure>> deleteAccount() async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.deleteAccount,
        method: RequestType.DELETE,
        converter: (response) {
          try {
            return response['data']['data'] != null;
          } catch (e) {
            throw Exception(e);
          }
        },
      );
      return response;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Either<bool, Failure>> logout() async {
    try {
      final response = await client.makeRequest(
        method: RequestType.POST,
        url: ApiConstants.logout,
        converter: (response) {
          try {
            return response['data']['status'] == 200;
          } catch (e) {
            throw Exception(e);
          }
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<bool, Failure>> updateFCM(Map<String, dynamic> body) async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.updateFcmToken,
        data: body,
        method: RequestType.POST,
        converter: (response) {
          try {
            return response['data']['data'] != null;
          } catch (e) {
            throw Exception(e);
          }
        },
      );
      return response;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Either<bool, Failure>> sendOtp(Map<String, dynamic> body) async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.sendOtp,
        method: RequestType.POST,
        data: body,
        converter: (response) {
          try {
            return response['code'] == 200;
          } catch (e) {
            throw Exception(e);
          }
        },
      );
      return response;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Either<UserModel, Failure>> verifyOtp(
      Map<String, dynamic> body) async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.verify,
        data: body,
        method: RequestType.POST,
        converter: (response) {
          try {
            return UserModel.fromJson(
                response['data']['data'] as Map<String, dynamic>);
          } catch (e) {
            throw Exception(e);
          }
        },
      );
      return response;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Either<bool, Failure>> verifyRegisterOtp(
      Map<String, dynamic> body) async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.verifyRegisterOtp,
        data: body,
        method: RequestType.POST,
        converter: (response) {
          try {
            return true;
          } catch (e) {
            throw Exception(e);
          }
        },
      );
      return response;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Either<UserModel, Failure>> getProfile() async {
    try {
      final response = await client.makeRequest(
        method: RequestType.GET,
        url: ApiConstants.profile,
        converter: (response) {
          try {
            return UserModel.fromJson(
                response['data']['data'] as Map<String, dynamic>);
          } catch (e) {
            throw Exception(e);
          }
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<List<RegionModel>, Failure>> getCities(Body body) async {
    final id = body['state_id'];
    final response = await client.makeRequest(
      url: '${ApiConstants.getCities}/$id',
      method: RequestType.GET,
      converter: (response) {
        try {
          return (response['data']['data'] as List)
              .map((item) => RegionModel.fromJson(item))
              .toList();
        } catch (e) {
          throw Exception(e);
        }
      },
    );
    return response;
  }

  @override
  Future<Either<AppConfigurationModel, Failure>> getAppConfigration() async {
    final response = await client.makeRequest(
      url: ApiConstants.getAppConfiguration,
      method: RequestType.GET,
      converter: (response) {
        return AppConfigurationModel.fromJson(response['data']);
      },
    );
    return response;
  }

  @override
  Future<Either<RealtimeConfigurationModel, Failure>>
      getRealtimeConfiguration() async {
    final response = await client.makeRequest(
      url: ApiConstants.realtimeConfiguration,
      method: RequestType.GET,
      converter: (response) {
        return RealtimeConfigurationModel.fromJson(response['data']);
      },
    );
    return response;
  }
}
