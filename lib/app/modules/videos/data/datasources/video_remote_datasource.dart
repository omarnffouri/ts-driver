import 'package:dartz/dartz.dart';

import '../../../../core/data/connection/api_constants.dart';
import '../../../../core/data/connection/dio_client.dart';
import '../../../../core/data/error/failures.dart';
import '../../../../core/enum/http_request_type.dart';
import '../../../../core/values/constants.dart';
import '../models/video_model.dart';

abstract class IVideoRemoteDataSource {
  Future<Either<List<VideoModel>, Failure>> getVideos();
  Future<Either<bool, Failure>> updateVideo(MapBody body);
}

class VideoRemoteDataSourceImpl implements IVideoRemoteDataSource {
  final DioClient client;
  VideoRemoteDataSourceImpl({required this.client});
  @override
  Future<Either<List<VideoModel>, Failure>> getVideos() async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.getVideos,
        converter: (response) {
          try {
            return (response['data']['data'] as List)
                .map((e) => VideoModel.fromJson(e))
                .toList();
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
  Future<Either<bool, Failure>> updateVideo(MapBody body) async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.updateVideo,
        data: body,
        method: RequestType.PUT,
        converter: (response) {
          try {
            return response['data']['data']["title"] == 'success';
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
}
