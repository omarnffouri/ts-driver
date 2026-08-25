import 'package:ts_driver/app/core/gen/assets.gen.dart';

enum JobCategory {
  driver,
  ownerOperator,
  ownerPartner,
}

extension JobCategoryExtension on JobCategory {
  static JobCategory? fromApiValue(String value) {
    switch (value) {
      case 'cat_driver':
        return JobCategory.driver;
      case 'cat_owner_operator':
        return JobCategory.ownerOperator;
      case 'cat_owner_partner':
        return JobCategory.ownerPartner;
      default:
        return null;
    }
  }

  String get displayName {
    switch (this) {
      case JobCategory.driver:
        return "I'm a Driver";
      case JobCategory.ownerOperator:
        return "I'm an Owner-Operator";
      case JobCategory.ownerPartner:
        return "I'm a Partner";
    }
  }

  String get apiValue {
    switch (this) {
      case JobCategory.driver:
        return 'cat_driver';
      case JobCategory.ownerOperator:
        return 'cat_owner_operator';
      case JobCategory.ownerPartner:
        return 'cat_owner_partner';
    }
  }

  String get imagePath {
    switch (this) {
      case JobCategory.driver:
        return Assets.images.truckDriver.path;
      case JobCategory.ownerOperator:
        return Assets.images.ownerOpeator.path;
      case JobCategory.ownerPartner:
        return Assets.images.truckPartner.path;
    }
  }
}
