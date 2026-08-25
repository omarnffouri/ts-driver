import 'package:ts_driver/app/modules/auth/domain/entities/app_configration_entity.dart';

import 'region_model.dart';
import 'terms_model.dart';

class AppConfigurationModel extends AppConfiguration {
  const AppConfigurationModel({
    super.termsAndConditions,
    super.states,
    super.isOtpEnabled,
  });

  factory AppConfigurationModel.fromJson(Map<String, dynamic> json) =>
      AppConfigurationModel(
        termsAndConditions: json["terms-and-conditions"] == null
            ? null
            : TermsModel.fromJson(json["terms-and-conditions"]),
        states: json["states"] == null
            ? []
            : List<RegionModel>.from(
                json["states"]!.map((x) => RegionModel.fromJson(x))),
        isOtpEnabled: json["is_otp_enabled"],
      );
}
