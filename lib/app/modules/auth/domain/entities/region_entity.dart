import 'package:equatable/equatable.dart';

class RegionEntity extends Equatable {
  final int? id;
  final String? name;

  const RegionEntity({this.id, this.name});

  @override
  List<Object?> get props => [id, name];
}
