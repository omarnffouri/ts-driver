import 'dart:developer';

import 'package:awesome_dio_interceptor/awesome_dio_interceptor.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ts_driver/app/core/data/error/exceptions.dart';

import '../../enum/http_request_type.dart';
import '../error/failures.dart';
import '../../values/constants.dart';
import 'api_constants.dart';
import 'http_handler.dart';

typedef ResponseConverter<T> = T Function(dynamic response);

class DioClient {
  DioClient._internal();
  static final _singleton = DioClient._internal();
  factory DioClient() => _singleton;

  static Dio createDio() {
    var dio = Dio(BaseOptions(
      baseUrl: ApiConstants.kServerURL,
      contentType: 'application/json',
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
    ));

    // add interceptors to dio
    dio.interceptors.addAll({
      AppInterceptors(dio),
      AwesomeDioInterceptor(
        logRequestTimeout: false,
        logRequestHeaders: false,
        logResponseHeaders: false,
        logger: (log) {
        },
      )
    });
    return dio;
  }

  Future<Either<T, Failure>> makeRequest<T>({
    required String url,
    RequestType method = RequestType.GET,
    Object? data,
    Map<String, dynamic>? queryParams,
    required ResponseConverter<T> converter,
    bool isIsolate = false,
  }) async {
    try {
      Stopwatch stopwatch = Stopwatch();
      stopwatch.start();

      Response<dynamic> response;
      switch (method) {
        case RequestType.POST:
          response = await createDio().post(
            url,
            data: data,
            queryParameters: queryParams,
          );
          break;
        case RequestType.PUT:
          response = await createDio().put(
            url,
            data: data,
            queryParameters: queryParams,
          );
          break;
        case RequestType.PATCH:
          response = await createDio().patch(
            url,
            data: data,
            queryParameters: queryParams,
          );
          break;
        case RequestType.DELETE:
          response = await createDio().delete(
            url,
            data: data,
            queryParameters: queryParams,
          );
          break;
        default:
          response = await createDio().get(
            url,
            data: data,
            queryParameters: queryParams,
          );
      }

      stopwatch.stop();
      log('$url request time >>> ${stopwatch.elapsedMilliseconds / 1000.0}');
      if ((response.statusCode ?? 0) != 200 &&
          (response.statusCode ?? 0) != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }

      if (!isIsolate) {
        return Left(converter(response.data));
      }

      final result = await compute(converter, response.data);
      return Left(result);
    } on DioException catch (e) {
      if (e.response?.data['message'] != null) {
        return Right(
          ServerFailure(
            title: "Error",
            message: e.response?.data['message'] as String,
            code: e.response?.statusCode as int,
          ),
        );
      } else if (e.response?.data['data']['errors'] != null) {
        return Right(
          ServerFailure(
            title: e.response?.data['data']['errors'][0]['title'] as String,
            message: e.response?.data['data']['errors'][0]['message'] as String,
            code: e.response?.data['data']['status'] as int,
          ),
        );
      } else {
        return Right(
          ServerFailure(
            title: '',
            message:
                e.response?.data['data']['error']['message'] as String? ?? "",
            // message: e.response?.data['error']['detail'] as String,
          ),
        );
      }
    }
  }
}

class AppInterceptors extends Interceptor {
  final Dio dio;

  AppInterceptors(this.dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    if (!options.path.contains('applicants/login') &&
        !options.path.contains('application') &&
        !options.path.contains('getStates')) {
      options.headers['Authorization'] =
          "Bearer ${CommonVariables.settings.read(TOKEN)}";

    }
    if (options.path.contains(ApiConstants.createInspection)) {
      options.headers['Content-Type'] = 'multipart/form-data';
    }
    return handler.next(options);
    //todo: add token refresh logic
    // var accessToken = await TokenRepository().getAccessToken();

    // if (accessToken != null) {
    //   var expiration = await TokenRepository().getAccessTokenRemainingTime();

    //   if (expiration.inSeconds < 60) {
    //     dio.interceptors.requestLock.lock();

    //     // Call the refresh endpoint to get a new token
    //     await UserService()
    //         .refresh()
    //         .then((response) async {
    //       await TokenRepository().persistAccessToken(response.accessToken);
    //       accessToken = response.accessToken;
    //     }).catchError((error, stackTrace) {
    //       handler.reject(error, true);
    //     }).whenComplete(() => dio.interceptors.requestLock.unlock());
    //   }

    //   options.headers['Authorization'] = 'Bearer $accessToken';
    //   }

    //   return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw DeadlineExceededException(err.requestOptions);
      case DioExceptionType.cancel:
        break;
      case DioExceptionType.unknown:
        throw UnknownException();
      case DioExceptionType.badCertificate:
        throw BadRequestException(err.requestOptions);
      case DioExceptionType.badResponse:
        httpHandler(err);
      case DioExceptionType.connectionError:
        throw NoInternetConnectionException(err.requestOptions);
    }
    return handler.next(err);
  }
}
