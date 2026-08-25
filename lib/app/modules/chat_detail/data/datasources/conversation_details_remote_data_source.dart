import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/enum/http_request_type.dart';
import 'package:ts_driver/app/modules/chat_detail/data/models/conversation_details_model.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/get_previous_messages_params.dart';

import '../../../../core/data/connection/api_constants.dart';
import '../../../../core/data/connection/dio_client.dart';
import '../../../../core/data/error/failures.dart';

abstract class IConversationDetailsRemoteDataSource {
  Future<Either<ConversationDetailsEntity, Failure>> getConversationDetails(
      String conversationId);

  Future<Either<List<ConversationMessageEntity>, Failure>> getPreviousMessages(
      GetPreviousMessagesParams params);
}

class ConversationDetailsRemoteDataSourceImpl
    implements IConversationDetailsRemoteDataSource {
  final DioClient client;

  ConversationDetailsRemoteDataSourceImpl({required this.client});

  @override
  Future<Either<ConversationDetailsEntity, Failure>> getConversationDetails(
      String conversationId) async {
    try {
      final response = await client.makeRequest(
        url: '${ApiConstants.getConversationDetails}/$conversationId',
        method: RequestType.GET,
        converter: (response) {
          try {
            return ConversationDetailsModel.fromJson(response);
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
  Future<Either<List<ConversationMessageEntity>, Failure>> getPreviousMessages(
      GetPreviousMessagesParams params) async {
    try {
      final response = await client.makeRequest(
        url: '${ApiConstants.getConversationDetails}/${params.conversationId}',
        method: RequestType.GET,
        queryParams: {'lastMessageId': params.lastMessageId},
        converter: (response) {
          try {
            return ConversationDetailsModel.fromJson(response).messages ?? [];
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
