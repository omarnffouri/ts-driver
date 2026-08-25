import '../../../shipments/domain/entities/shipment_entity.dart';

/// Best human label for a trip leg: company name, else "City, State", else the
/// fallback. Treats empty / literal "null" strings as missing.
String locationLabel(LocEntity? leg, String fallback) {
  final location = leg?.location;
  final company = location?.companyName?.trim();
  if (company != null && company.isNotEmpty && company != 'null') {
    return company;
  }

  final city = location?.city?.trim();
  final state = location?.stateName?.trim();
  final hasCity = city != null && city.isNotEmpty && city != 'null';
  final hasState = state != null && state.isNotEmpty && state != 'null';

  if (hasCity && hasState) return '$city, $state';
  if (hasCity) return city;
  if (hasState) return state;
  return fallback;
}

String valueOrFallback(String? value, String fallback) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty || trimmed == 'null') {
    return fallback;
  }
  return trimmed;
}
