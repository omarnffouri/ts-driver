import 'package:equatable/equatable.dart';

class WebsocketConfiguration extends Equatable {
  final String? provider;
  final String? broadcaster;
  final String? appId;
  final String? key;
  final String? host;
  final int? port;
  final String? scheme;
  final String? path;
  final bool? forceTls;
  final List<String> enabledTransports;
  final String? authEndpoint;

  const WebsocketConfiguration({
    this.provider,
    this.broadcaster,
    this.appId,
    this.key,
    this.host,
    this.port,
    this.scheme,
    this.path,
    this.forceTls,
    this.enabledTransports = const [],
    this.authEndpoint,
  });

  bool get isValid =>
      (key?.isNotEmpty ?? false) &&
      (host?.isNotEmpty ?? false) &&
      (port ?? 0) > 0 &&
      (authEndpoint?.isNotEmpty ?? false);

  @override
  List<Object?> get props => [
        provider,
        broadcaster,
        appId,
        key,
        host,
        port,
        scheme,
        path,
        forceTls,
        enabledTransports,
        authEndpoint,
      ];
}
