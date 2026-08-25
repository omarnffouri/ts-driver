import 'package:ts_driver/app/modules/auth/domain/entities/terms_condtions_entitiy.dart';

class TermsModel extends TermsEntity {
  TermsModel({
    required int id,
    required String description,
  }) : super(id: id, description: description);

  factory TermsModel.fromJson(Map<String, dynamic> json) {
    return TermsModel(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
    );
  }
}
