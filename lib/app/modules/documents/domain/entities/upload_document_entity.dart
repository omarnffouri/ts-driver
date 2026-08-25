import 'package:equatable/equatable.dart';

class UploadDocumentEntity extends Equatable {
  final int? id;
  final String? expirationDate;
  final String? document;
  final bool? hasExpiration;

  const UploadDocumentEntity({
    this.id,
    this.expirationDate,
    this.document,
    this.hasExpiration,
  });

  UploadDocumentEntity copyWith({
    int? id,
    String? fileType,
    String? expirationDate,
    String? document,
    bool? hasExpiration,
  }) =>
      UploadDocumentEntity(
        id: id ?? this.id,
        expirationDate: expirationDate ?? this.expirationDate,
        document: document ?? this.document,
        hasExpiration: hasExpiration ?? this.hasExpiration,
      );

  @override
  List<Object?> get props => [
        id,
        expirationDate,
        document,
        hasExpiration,
      ];
}
