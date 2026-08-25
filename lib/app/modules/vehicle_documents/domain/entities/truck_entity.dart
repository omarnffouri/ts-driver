// To parse this JSON data, do
//
//     final truckModel = truckModelFromJson(jsonString);

import 'package:equatable/equatable.dart';

class TruckEntity extends Equatable {
  final String? id;
  final String? name;
  final String? path;

  const TruckEntity({
    this.id,
    this.name,
    this.path,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        path,
      ];
}
