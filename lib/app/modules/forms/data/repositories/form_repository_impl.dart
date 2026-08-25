import 'package:dartz/dartz.dart';

import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/modules/forms/data/models/signed_form_model.dart';
import '../../../../core/data/connection/network_info.dart';
import '../../../../core/data/error/exceptions.dart';
import '../../../../core/services/injection_service.dart';
import '../../domain/repositories/form_repository.dart';
import '../datasources/form_remote_datasource.dart';
import '../models/form_model.dart';

class FormRepositoryImpl implements IFormRepository {
  IFormRemoteDataSource formDataSource = sl<IFormRemoteDataSource>();
  NetworkInfoImpl networkInfo = NetworkInfoImpl(dataConnectionChecker: sl());

  FormRepositoryImpl({required this.formDataSource});

  @override
  Future<Either<List<FormModel>, Failure>> getAllForms() async {
    if (await networkInfo.isConnected) {
      try {
        final getAllFormsResponse = await formDataSource.getAllForms();
        return getAllFormsResponse.fold(
          (List<FormModel> forms) => Left(forms),
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
  Future<Either<List<SignedFormModel>, Failure>> getAllSignedForms() async {
    if (await networkInfo.isConnected) {
      try {
        final getAllFormsResponse = await formDataSource.getAllSignedForms();
        return getAllFormsResponse.fold(
          (List<SignedFormModel> forms) => Left(forms),
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
  Future<Either<bool, Failure>> signForm(Map<String, dynamic> params) async {
    if (await networkInfo.isConnected) {
      try {
        final getAllFormsResponse = await formDataSource.signForm(params);
        return getAllFormsResponse.fold(
          (bool forms) => Left(forms),
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
  Future<Either<bool, Failure>> updateAttachmentStatus(
      Map<String, dynamic> params) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await formDataSource.updateAttachmentStatus(params);
        return response.fold(
          (bool forms) => Left(forms),
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
