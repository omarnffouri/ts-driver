import 'package:ts_driver/app/core/helpers/extensions.dart';

import '../../modules/auth/domain/entities/user_entity.dart';

enum AccessLevel {
  driverOnly,
  partnerOnly,
  both,
}

extension AccessLvlExt on AccessLevel {
  // A function to return current access level can view contents.
  // before hire the applicant we determine the access level based on
  // job category and after hire we determine the access level based on roles.
  static AccessLevel getAccessLevel(UserEntity user) {
    // check if the user does not have any roles
    if (user.personalDetails?.roles == null ||
        user.personalDetails?.roles?.isEmpty == true) {
      // return access level based on job category
      if (user.isOwnerPartner()) {
        return AccessLevel.partnerOnly;
      } else {
        return AccessLevel.driverOnly;
      }
    } else {
      // return access level based on roles
      if (user.hasOwnerPartnerPrivileges()) {
        return AccessLevel.both;
      } else if (user.hasOwnerPartnerRole()) {
        return AccessLevel.partnerOnly;
      } else {
        return AccessLevel.driverOnly;
      }
    }
  }

  // Get a string representation of the access level for display purposes.
  String get nameForDisplay {
    switch (this) {
      case AccessLevel.driverOnly:
        return "Driver";
      case AccessLevel.partnerOnly:
        return "Partner";
      case AccessLevel.both:
        return "Driver & Partner";
    }
  }
}
