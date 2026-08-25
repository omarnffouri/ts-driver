import 'package:ts_driver/app/modules/documents/data/datasources/document_remote_data_source.dart';

import 'package:ts_driver/app/core/data/error/failures.dart';

import 'package:dartz/dartz.dart';

import '../../../../core/data/connection/network_info.dart';
import '../../../../core/data/error/exceptions.dart';
import '../../../../core/services/injection_service.dart';
import '../../domain/repositories/document_repository.dart';
import '../models/document_model.dart';

class DocumentRepositoryImpl implements IDocumentRepository {
  NetworkInfoImpl networkInfo = NetworkInfoImpl(dataConnectionChecker: sl());
  IDocumentRemoteDataSource documentDataSource =
      sl<IDocumentRemoteDataSource>();
  DocumentRepositoryImpl({required this.documentDataSource});

  @override
  Future<Either<List<DocumentModel>, Failure>> getAllDocuments() async {
    if (await networkInfo.isConnected) {
      try {
        final documentsResponse = await documentDataSource.getAllDocuments();
        return documentsResponse.fold(
          (documents) => Left(documents),
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
  Future<Either<bool, Failure>> uploadDocuments(
      Map<String, dynamic> params) async {
    if (await networkInfo.isConnected) {
      try {
        final documentsResponse =
            await documentDataSource.uploadDocuments(params);
        return documentsResponse.fold(
          (bool isUploaded) => Left(isUploaded),
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
