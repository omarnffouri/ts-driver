import 'package:ts_driver/app/modules/chat/data/data_sources/conversation_remote_data_source.dart';
import 'package:ts_driver/app/modules/chat/data/models/conversation_model.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/contact_entity.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/create_conversation_entity.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/group_conversation_entity.dart';
import 'package:ts_driver/app/modules/chat/domain/params/create_conversation_params.dart';
import 'package:ts_driver/app/modules/chat/domain/repositories/conversation_repository.dart';

import 'package:ts_driver/app/core/data/error/failures.dart';

import 'package:dartz/dartz.dart';

import '../../../../core/data/connection/network_info.dart';
import '../../../../core/data/error/exceptions.dart';
import '../../../../core/services/injection_service.dart';

class ConversationRepositoryImpl implements IConversationRepository {
  NetworkInfoImpl networkInfo = NetworkInfoImpl(dataConnectionChecker: sl());
  IConversationRemoteDataSource conversationDataSource =
      sl<IConversationRemoteDataSource>();
  ConversationRepositoryImpl({required this.conversationDataSource});

  @override
  Future<Either<List<ConversationModel>, Failure>> getAllConversations() async {
    if (await networkInfo.isConnected) {
      try {
        final documentsResponse =
            await conversationDataSource.getAllConversations();
        return documentsResponse.fold(
          (conversations) => Left(conversations),
          (failure) => Right(failure),
        );
      } on ServerException catch (e) {
        return Right(ServerFailure(title: '', message: e.message));
      }
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }

  @override
  Future<Either<List<ContactEntity>, Failure>> getAllContacts() async {
    if (await networkInfo.isConnected) {
      try {
        final contactsResponse = await conversationDataSource.getAllContacts();
        return contactsResponse.fold(
          (contacts) => Left(contacts),
          (failure) => Right(failure),
        );
      } on ServerException catch (e) {
        return Right(ServerFailure(title: '', message: e.message));
      }
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }

  @override
  Future<Either<CreateConversationEntity, Failure>> createNewConversation(
      CreateConversationParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final newConversationResponse =
            await conversationDataSource.createNewConversation(params);
        return newConversationResponse.fold(
          (newConversation) => Left(newConversation),
          (failure) => Right(failure),
        );
      } on ServerException catch (e) {
        return Right(ServerFailure(title: '', message: e.message));
      }
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }

  @override
  Future<Either<List<GroupConversationEntity>, Failure>>
      getAllGroupConversations() async {
    if (await networkInfo.isConnected) {
      try {
        final groupConversationsResponse =
            await conversationDataSource.getAllGroupConversations();
        return groupConversationsResponse.fold(
          (groupConversations) => Left(groupConversations),
          (failure) => Right(failure),
        );
      } on ServerException catch (e) {
        return Right(ServerFailure(title: '', message: e.message));
      }
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }
}
