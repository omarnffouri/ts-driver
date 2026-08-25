import 'package:ts_driver/app/modules/settlements/domain/entities/partner_driver_entity.dart';

class PartnerDriverModel extends PartnerDriverEntity {
  PartnerDriverModel({
    required super.id,
    required super.name,
    required super.canViewSettlements,
  });

  factory PartnerDriverModel.fromJson(Map<String, dynamic> json) {
    return PartnerDriverModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      canViewSettlements: json['can_view_settlements'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'can_view_settlements': canViewSettlements,
      };
}
