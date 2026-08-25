import 'package:dartz/dartz.dart';
import 'package:ts_driver/app/core/data/error/error_handler.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';

Future<Either<T, Failure>> executeAndHandleError<T>(
  Future<Either<T, Failure>> Function() function,
) async {
  try {
    final result = await function();
    return result.fold(
      (data) => Left(data),
      (failure) => Right(failure),
    );
  } catch (e) {
    final failure = ErrorHandler.handle(e).failure;
    return Right(failure);
  }
}
