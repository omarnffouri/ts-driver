import 'dart:io';

/// A captured damage: its category id + label and the photo file. Shared by the
/// trailer and truck inspection flows.
class InspectionDamage {
  int damageId;
  String damage;
  File image;

  InspectionDamage({
    required this.damageId,
    required this.damage,
    required this.image,
  });
}
