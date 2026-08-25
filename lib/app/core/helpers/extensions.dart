import 'package:flutter/material.dart';

import '../../modules/auth/domain/entities/user_entity.dart';

extension UserHelper on UserEntity {
  bool isDriver() {
    return personalDetails?.activeApplication?.jobCategory == 'Driver';
  }

  bool isOwnerPartner() {
    return personalDetails?.activeApplication?.jobCategory == 'Owner Partner';
  }

  bool isOwnerOperator() {
    return personalDetails?.activeApplication?.jobCategory == 'Owner Operator';
  }

  bool hasDriverRole() {
    return hasAnyRole(['driver']);
  }

  bool hasOwnerPartnerRole() {
    return hasAnyRole(['owner_partner']);
  }

  bool hasOwnerPartnerPrivileges() {
    return hasAllRoles(['owner_partner', 'driver']);
  }
}

extension ListHelper<T> on List<T> {
  bool isNullOrEmpty() {
    return isEmpty;
  }

  bool isNotNullOrEmpty() {
    return isNotEmpty;
  }
}

extension StringHelper on String {
  bool isNullOrEmpty() {
    return isEmpty || this == 'null';
  }

  bool isNotNullOrEmpty() {
    return isNotEmpty;
  }

  String dollar() {
    return '\$$this';
  }

  String decimalPattern() {
    if (isNullOrEmpty()) return '';
    try {
      return num.parse(this).toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    } catch (e) {
      return '';
    }
  }
}

extension ColorAplha on Color {
  Color applyOpacity(double opacity) {
    return withAlpha((255.0 * opacity).round());
  }
}
