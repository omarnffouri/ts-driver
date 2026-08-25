import 'package:flutter/services.dart' show appFlavor;

enum Environment {
  dev('dev', 'dev.ts-portal.com'),
  staging('staging', 'staging.ts-portal.com'),
  production('prod', 'ts-portal.com');

  final String flavorName;
  final String host;
  const Environment(this.flavorName, this.host);

  // Tests and unflavored builds run with a null flavor and get production;
  // an unrecognized flavor fails at first startup instead of silently
  // defaulting to production.
  static Environment get current {
    if (appFlavor == null) return production;
    return values.firstWhere(
      (e) => e.flavorName == appFlavor,
      orElse: () => throw StateError('Unknown build flavor: $appFlavor'),
    );
  }
}
