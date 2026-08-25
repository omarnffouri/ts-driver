import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/connection/api_constants.dart';
import 'package:ts_driver/app/modules/chat/data/models/contact_model.dart';
import 'package:ts_driver/app/modules/chat/data/models/conversation_model.dart';
import 'package:ts_driver/app/modules/chat/data/models/create_conversation_model.dart';
import 'package:ts_driver/app/modules/chat/data/models/group_conversation_model.dart';
import 'package:ts_driver/app/modules/chat/domain/params/create_conversation_params.dart';

import '../../../../core/data/connection/dio_client.dart';
import '../../../../core/data/error/failures.dart';
import '../../../../core/enum/http_request_type.dart';

abstract class IConversationRemoteDataSource {
  Future<Either<List<ConversationModel>, Failure>> getAllConversations();
  Future<Either<List<ContactModel>, Failure>> getAllContacts();
  Future<Either<CreateConversationModel, Failure>> createNewConversation(
      CreateConversationParams params);
  Future<Either<List<GroupConversationModel>, Failure>>
      getAllGroupConversations();
}

class ConversationRemoteDataSourceImpl
    implements IConversationRemoteDataSource {
  final DioClient client;

  ConversationRemoteDataSourceImpl({required this.client});

  @override
  Future<Either<List<ConversationModel>, Failure>> getAllConversations() async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.getConversations,
        method: RequestType.GET,
        converter: (response) {
          try {
            return (response as List)
                .map((e) => ConversationModel.fromJson(e))
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
  Future<Either<List<ContactModel>, Failure>> getAllContacts() async {
    try {
      final response = await client.makeRequest(
        url: ApiConstants.getContacts,
        method: RequestType.GET,
        converter: (response) {
          try {
            return (response as List)
                .map((e) => ContactModel.fromJson(e))
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
  Future<Either<CreateConversationModel, Failure>> createNewConversation(
      CreateConversationParams params) async {
    try {
      final response = await client.makeRequest(
        url:
            '${ApiConstants.createConversation}/${params.userType}/${params.userId}',
        method: RequestType.GET,
        converter: (response) {
          try {
            return CreateConversationModel.fromJson(response);
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
  Future<Either<List<GroupConversationModel>, Failure>>
      getAllGroupConversations() async {
    try {
      final response = await client.makeRequest(
        url: "${ApiConstants.getGroupConversations}?type=group_by_head",
        method: RequestType.GET,
        converter: (response) {
          try {
            final list = (response as List);

            final map = list.map((e) {
              if (e["conversations"] == null) {
                return null;
              }
              return GroupConversationModel.fromJsonApi(e);
            }).toList();

            final filter = map
                .where((element) => element != null)
                .map((item) => item!)
                .toList();

            return filter;
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
