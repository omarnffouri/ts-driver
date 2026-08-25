import 'package:ts_driver/app/modules/auth/domain/entities/agora_configuration_entity.dart';

class AgoraConfigurationModel extends AgoraConfiguration {
  const AgoraConfigurationModel({
    String? appId,
    String? appCertificate,
    String? appCustomerKey,
    String? appCustomerSecret,
    String? notificationSecret,
  }) : super(
          appId: appId,
          appCertificate: appCertificate,
          appCustomerKey: appCustomerKey,
          appCustomerSecret: appCustomerSecret,
          notificationSecret: notificationSecret,
        );

  factory AgoraConfigurationModel.fromJson(Map<String, dynamic> json) {
    return AgoraConfigurationModel(
      appId: json['app_id'] as String?,
      appCertificate: json['app_certificate'] as String?,
      appCustomerKey: json['app_customer_key'] as String?,
      appCustomerSecret: json['app_customer_secret'] as String?,
      notificationSecret: json['notification_secret'] as String?,
    );
  }

  factory AgoraConfigurationModel.fromEntity(AgoraConfiguration entity) {
    return AgoraConfigurationModel(
      appId: entity.appId,
      appCertificate: entity.appCertificate,
      appCustomerKey: entity.appCustomerKey,
      appCustomerSecret: entity.appCustomerSecret,
      notificationSecret: entity.notificationSecret,
    );
  }

  Map<String, dynamic> toJson() => {
        'app_id': appId,
        'app_certificate': appCertificate,
        'app_customer_key': appCustomerKey,
        'app_customer_secret': appCustomerSecret,
        'notification_secret': notificationSecret,
      };
}
