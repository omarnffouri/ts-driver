import 'package:equatable/equatable.dart';

import 'agora_configuration_entity.dart';
import 'websocket_configuration_entity.dart';

class RealtimeConfiguration extends Equatable {
  final WebsocketConfiguration? websocket;
  final AgoraConfiguration? agora;
  final String? configVersion;

  const RealtimeConfiguration({
    this.websocket,
    this.agora,
    this.configVersion,
  });

  bool get isValid => websocket?.isValid ?? false;

  @override
  List<Object?> get props => [websocket, agora, configVersion];
}
