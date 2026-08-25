// // ignore_for_file: avoid_dynamic_calls

// import 'package:dio/dio.dart' as dio;
// import 'package:ts_driver/app/core/data/error/exceptions.dart';

// dio.Response<dynamic> responseHandler(
//   dio.Response<dynamic> response,
// ) {
//   switch (response.statusCode) {
//     case 200:
//     case 201:
//     case 202:
//       return response;
//     case 401:
//       return throw ServerException(
//           message: 'Autherization problem, Please login agian');
//     case 403:
//       return throw ServerException(
//         message: 'Error occurred please check internet and retry.',
//       );
//     case 404:
//       return throw ServerException(message: 'Url not found');
//     case 500:
//       return throw ServerException(message: "Server Error please retry later");
//     default:
//       return throw ServerException(message: 'Something Went wrong, try again');
//   }
// }

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/controllers/auth_controller.dart';

import '../error/exceptions.dart';

Future<dynamic> httpHandler(DioException err) async {
  final authController = Get.find<AuthController>();
  switch (err.response?.statusCode) {
    case 400:
      throw BadRequestException(err.requestOptions);
    case 401:
      authController.logout(isServerException: true);
      throw UnauthorizedException(err.requestOptions);
    case 403:
      throw UnauthorizedException(err.requestOptions);
    case 404:
      throw NotFoundException(err.requestOptions);
    case 409:
      throw ConflictException(err.requestOptions);
    case 500:
      throw InternalServerErrorException(err.requestOptions);
    default:
      throw UnknownException();
  }
}
