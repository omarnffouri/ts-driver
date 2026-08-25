import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/data/error/failures.dart';
import '../models/trailer_model.dart';
import '../models/truck_model.dart';

abstract class IVehicleDocumentsLocalDataSource {
  Future<Either<List<TruckModel>, Failure>> getAllTruckDocuments();
  Future<bool> cacheTruckDocuments(List<TruckModel> documentsToCache);
  Future<Either<List<TrailerModel>, Failure>> getAllTrailerDocuments();
  Future<bool> cacheTrailerDocuments(List<TrailerModel> documentsToCache);
}

class VehicleDocumentsLocalDataSourceImpl
    implements IVehicleDocumentsLocalDataSource {
  final SharedPreferences prefs;
  VehicleDocumentsLocalDataSourceImpl({required this.prefs});

  @override
  Future<Either<List<TruckModel>, Failure>> getAllTruckDocuments() async {
    try {
      final jsonString = prefs.getString('truck_documents');

      if (jsonString == null || jsonString.isEmpty) {
        return const Right(EmptyCacheFailure(message: 'No data found'));
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      final documents = jsonList
          .map((json) => TruckModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Left(documents);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> cacheTruckDocuments(List<TruckModel> documentsToCache) async {
    try {
      final jsonString = jsonEncode(
        documentsToCache.map((truck) => truck.toJson()).toList(),
      );
      final success = await prefs.setString('truck_documents', jsonString);
      if (success) {
        return Future.value(true);
      } else {
        return Future.value(false);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<List<TrailerModel>, Failure>> getAllTrailerDocuments() async {
    try {
      final jsonString = prefs.getString('trailer_documents');

      if (jsonString == null || jsonString.isEmpty) {
        return const Right(EmptyCacheFailure(message: 'No data found'));
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      final documents = jsonList
          .map((json) => TrailerModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Left(documents);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> cacheTrailerDocuments(
      List<TrailerModel> documentsToCache) async {
    try {
      final jsonString = jsonEncode(
          documentsToCache.map((trailer) => trailer.toJson()).toList());
      final success = await prefs.setString('trailer_documents', jsonString);

      if (success) {
        return Future.value(true);
      } else {
        return Future.value(false);
      }
    } catch (e) {
      rethrow;
    }
  }
}
