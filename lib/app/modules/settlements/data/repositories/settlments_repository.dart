import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/helpers/base_response.dart';
import 'package:ts_driver/app/core/data/connection/network_info.dart';
import 'package:ts_driver/app/core/data/error/exceptions.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/modules/settlements/domain/entities/partner_driver_entity.dart';

import 'package:ts_driver/app/core/services/injection_service.dart';

import '../../domain/params/settlments_params.dart';
import '../../domain/params/update_partner_driver_permission_params.dart';
import '../../domain/repositories/settlments_repository.dart';
import '../data_sources/settlements_remote_data_source.dart';
import '../models/partner_settlement_data_model.dart';
import '../models/partner_settlement_details_model.dart';
import '../models/settlement_data_model.dart';
import '../models/settlement_details_model.dart';

class SettlementsRepositoryImp implements ISettlmentsRepository {
  NetworkInfoImpl networkInfo = NetworkInfoImpl(dataConnectionChecker: sl());

  final ISettlementsDataSource dataSource;

  SettlementsRepositoryImp({required this.dataSource});

  @override
  Future<Either<BaseResponse<List<SettlementDataModel>>, Failure>>
      getAllSettlements(SettlementParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await dataSource.getAllSettlements(params);
        return response.fold(
          (settlements) => Left(settlements),
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
  Future<Either<SettlementDetailsModel, Failure>> getSettlementDetails(
    String settlementId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await dataSource.getSettlementDetails(settlementId);
        return response.fold(
          (settlement) => Left(settlement),
          (failure) => Right(failure),
        );
      } on ServerException catch (e) {
        return Right(ServerFailure(title: '', message: e.message));
      } catch (e) {
        return Right(ServerFailure(title: '', message: e.toString()));
      }
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }

  @override
  Future<Either<List<PartnerSettlement>, Failure>> getAllPartnerSettlements(
      SettlementParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await dataSource.getAllParterSettlements(params);
        return response;
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
  Future<Either<PartnerSettlementDetailsModel, Failure>>
      getPartnerSettlementDetails(String settlementId) async {
    if (await networkInfo.isConnected) {
      try {
        final response =
            await dataSource.getPartnerSettlementDetails(settlementId);
        return response;
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
  Future<Either<List<PartnerDriverEntity>, Failure>> getPartnerDrivers() async {
    if (await networkInfo.isConnected) {
      try {
        final response = await dataSource.getPartnerDrivers();
        return response.fold(
          (drivers) => Left(drivers),
          (failure) => Right(failure),
        );
      } on ServerException catch (e) {
        return Right(ServerFailure(title: '', message: e.message));
      } catch (e) {
        return Right(ServerFailure(title: '', message: e.toString()));
      }
    } else {
      return const Right(
        OfflineFailure(message: 'No Internet, try again later'),
      );
    }
  }

  @override
  Future<Either<bool, Failure>> updatePartnerDriverState(
      UpdatePartnerDriverStateParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await dataSource.updatePartnerDriverState(params);
        return response.fold(
          (bool otp) => Left(otp),
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
