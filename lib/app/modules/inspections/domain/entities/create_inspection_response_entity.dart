import 'package:equatable/equatable.dart';

/// Pure domain entity — JSON (de)serialization lives in the data-layer model
/// [CreateInspectionResponseModel].
class CreateInspectionResponseEntity extends Equatable {
  final int? code;
  final String? status;
  final String? message;
  final List<dynamic>? payload;

  const CreateInspectionResponseEntity({
    this.code,
    this.status,
    this.message,
    this.payload,
  });

  @override
  List<Object?> get props => [code, status, message, payload];
}
