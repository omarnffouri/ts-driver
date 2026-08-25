import 'package:equatable/equatable.dart';

class SignedFormEntity extends Equatable {
  const SignedFormEntity({
    this.formName,
    this.signedFormUrl,
    this.createdAt,
    this.signedAt,
  });

  final String? formName;
  final String? signedFormUrl;
  final String? createdAt;
  final String? signedAt;

  @override
  List<Object?> get props => [formName, signedFormUrl, createdAt, signedAt];

  SignedFormEntity copyWith({
    String? formName,
    String? signedFormUrl,
    String? createdAt,
    String? signedAt,
  }) =>
      SignedFormEntity(
        formName: formName ?? this.formName,
        signedFormUrl: signedFormUrl ?? this.signedFormUrl,
        createdAt: createdAt ?? this.createdAt,
        signedAt: signedAt ?? this.signedAt,
      );
}
