import 'package:ts_driver/app/core/data/error/exceptions.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';

import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/get_previous_messages_params.dart';

import '../../../../core/data/connection/network_info.dart';
import '../../../../core/data/error/failures.dart';
import '../../../../core/services/injection_service.dart';
import '../../domain/repositories/conversation_details_repository.dart';
import '../datasources/conversation_details_remote_data_source.dart';

class ConversationDetailsRepositoryImpl extends IConversationDetailsRepository {
  ConversationDetailsRepositoryImpl(
      {required this.conversationDetailsRemoteDataSource});

  NetworkInfoImpl networkInfo = NetworkInfoImpl(dataConnectionChecker: sl());
  final IConversationDetailsRemoteDataSource
      conversationDetailsRemoteDataSource;

  @override
  Future<Either<ConversationDetailsEntity, Failure>> getConversationDetails(
      String conversationId) async {
    if (await networkInfo.isConnected) {
      try {
        final conversationDetailsResponse =
            await conversationDetailsRemoteDataSource
                .getConversationDetails(conversationId);
        return conversationDetailsResponse.fold(
          (conversationDeatils) => Left(conversationDeatils),
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
  Future<Either<List<ConversationMessageEntity>, Failure>> getPreviousMessages(
      GetPreviousMessagesParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final previousMessagesResponse =
            await conversationDetailsRemoteDataSource
                .getPreviousMessages(params);
        return previousMessagesResponse.fold(
          (previousMessages) => Left(previousMessages),
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
