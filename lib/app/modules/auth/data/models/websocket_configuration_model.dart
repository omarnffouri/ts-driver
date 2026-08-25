import 'package:ts_driver/app/modules/auth/domain/entities/websocket_configuration_entity.dart';

class WebsocketConfigurationModel extends WebsocketConfiguration {
  const WebsocketConfigurationModel({
    String? provider,
    String? broadcaster,
    String? appId,
    String? key,
    String? host,
    int? port,
    String? scheme,
    String? path,
    bool? forceTls,
    List<String> enabledTransports = const [],
    String? authEndpoint,
  }) : super(
          provider: provider,
          broadcaster: broadcaster,
          appId: appId,
          key: key,
          host: host,
          port: port,
          scheme: scheme,
          path: path,
          forceTls: forceTls,
          enabledTransports: enabledTransports,
          authEndpoint: authEndpoint,
        );

  factory WebsocketConfigurationModel.fromJson(Map<String, dynamic> json) {
    return WebsocketConfigurationModel(
      provider: json['provider'] as String?,
      broadcaster: json['broadcaster'] as String?,
      appId: json['app_id'] as String?,
      key: json['key'] as String?,
      host: json['host'] as String?,
      port: json['port'] is int
          ? json['port'] as int
          : int.tryParse(json['port']?.toString() ?? ''),
      scheme: json['scheme'] as String?,
      path: json['path'] as String?,
      forceTls: json.containsKey('force_tls')
          ? json['force_tls'] is bool
              ? json['force_tls'] as bool
              : json['force_tls'] == 1
          : null,
      enabledTransports: json['enabled_transports'] == null
          ? const []
          : List<String>.from(json['enabled_transports'] as List),
      authEndpoint: json['auth_endpoint'] as String?,
    );
  }

  factory WebsocketConfigurationModel.fromEntity(
      WebsocketConfiguration entity) {
    return WebsocketConfigurationModel(
      provider: entity.provider,
      broadcaster: entity.broadcaster,
      appId: entity.appId,
      key: entity.key,
      host: entity.host,
      port: entity.port,
      scheme: entity.scheme,
      path: entity.path,
      forceTls: entity.forceTls,
      enabledTransports: entity.enabledTransports,
      authEndpoint: entity.authEndpoint,
    );
  }

  Map<String, dynamic> toJson() => {
        'provider': provider,
        'broadcaster': broadcaster,
        'app_id': appId,
        'key': key,
        'host': host,
        'port': port,
        'scheme': scheme,
        'path': path,
        'force_tls': forceTls,
        'enabled_transports': enabledTransports,
        'auth_endpoint': authEndpoint,
      };
}
