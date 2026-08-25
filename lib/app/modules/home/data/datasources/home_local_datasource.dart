import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/modules/home/data/models/applicant_state.dart';

abstract class IHomeLocalDatasource {
  Future<Either<ApplicantState, Failure>> getApplicationState();
  Future<void> cacheApplicationState(ApplicantState applicantState);
}

class HomeLocalDatasourceImpl implements IHomeLocalDatasource {
  HomeLocalDatasourceImpl();
  @override
  Future<Either<ApplicantState, Failure>> getApplicationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('applicant_state');

      if (jsonString != null) {
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        final applicantState = ApplicantState.fromJson(jsonMap);
        return Left(applicantState);
      } else {
        return const Right(EmptyCacheFailure(message: 'No data found'));
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> cacheApplicationState(ApplicantState applicantState) async {
    // cache the data useing shared preference
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(applicantState.toJson());
    await prefs.setString('applicant_state', jsonString);
    return Future.value();
  }
}
