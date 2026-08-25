import 'package:equatable/equatable.dart';

/// Pure domain entities — JSON (de)serialization lives in the data-layer model
/// [InspectionOptionResponseModel].
class InspectionOptionResponseEntity extends Equatable {
  final int? code;
  final String? status;
  final InpectionOptionsPayloadEntity? payload;

  const InspectionOptionResponseEntity({
    this.code,
    this.status,
    this.payload,
  });

  @override
  List<Object?> get props => [code, status, payload];
}

class InpectionOptionsPayloadEntity extends Equatable {
  final List<InspectionOptionEntity>? categories;

  const InpectionOptionsPayloadEntity({this.categories});

  @override
  List<Object?> get props => [categories];
}

class InspectionOptionEntity extends Equatable {
  final int? id;
  final String? name;

  const InspectionOptionEntity({this.id, this.name});

  @override
  List<Object?> get props => [id, name];
}
