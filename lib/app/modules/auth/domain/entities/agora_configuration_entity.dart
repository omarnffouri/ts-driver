import 'package:equatable/equatable.dart';

class AgoraConfiguration extends Equatable {
  final String? appId;
  final String? appCertificate;
  final String? appCustomerKey;
  final String? appCustomerSecret;
  final String? notificationSecret;

  const AgoraConfiguration({
    this.appId,
    this.appCertificate,
    this.appCustomerKey,
    this.appCustomerSecret,
    this.notificationSecret,
  });

  @override
  List<Object?> get props => [
        appId,
        appCertificate,
        appCustomerKey,
        appCustomerSecret,
        notificationSecret,
      ];
}
