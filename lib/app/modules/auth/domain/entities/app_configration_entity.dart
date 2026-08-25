import 'package:equatable/equatable.dart';

import 'region_entity.dart';
import 'terms_condtions_entitiy.dart';

class AppConfiguration extends Equatable {
  final TermsEntity? termsAndConditions;
  final List<RegionEntity>? states;
  final bool? isOtpEnabled;

  const AppConfiguration({
    this.termsAndConditions,
    this.states,
    this.isOtpEnabled,
  });

  @override
  List<Object?> get props => [
        termsAndConditions,
        states,
        isOtpEnabled,
      ];
}
