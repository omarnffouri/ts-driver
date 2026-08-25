import 'package:ts_driver/app/modules/auth/domain/entities/agora_configuration_entity.dart';
import 'package:ts_driver/app/modules/auth/domain/entities/realtime_configuration_entity.dart';
import 'package:ts_driver/app/modules/auth/domain/entities/websocket_configuration_entity.dart';

import 'agora_configuration_model.dart';
import 'websocket_configuration_model.dart';

class RealtimeConfigurationModel extends RealtimeConfiguration {
  const RealtimeConfigurationModel({
    WebsocketConfiguration? websocket,
    AgoraConfiguration? agora,
    String? configVersion,
  }) : super(
          websocket: websocket,
          agora: agora,
          configVersion: configVersion,
        );

  factory RealtimeConfigurationModel.fromJson(Map<String, dynamic> json) {
    final websocketJson = json['websocket'];
    final agoraJson = json['agora'];
    return RealtimeConfigurationModel(
      websocket: websocketJson is Map
          ? WebsocketConfigurationModel.fromJson(
              Map<String, dynamic>.from(websocketJson))
          : null,
      agora: agoraJson is Map
          ? AgoraConfigurationModel.fromJson(
              Map<String, dynamic>.from(agoraJson))
          : null,
      configVersion: json['config_version']?.toString(),
    );
  }

  factory RealtimeConfigurationModel.fromEntity(RealtimeConfiguration entity) {
    return RealtimeConfigurationModel(
      websocket: entity.websocket,
      agora: entity.agora,
      configVersion: entity.configVersion,
    );
  }

  Map<String, dynamic> toJson() => {
        if (websocket != null)
          'websocket':
              WebsocketConfigurationModel.fromEntity(websocket!).toJson(),
        if (agora != null)
          'agora': AgoraConfigurationModel.fromEntity(agora!).toJson(),
        'config_version': configVersion,
      };
}
