import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class DocumentEntity extends Equatable {
  String? id;
  final String? message;
  final String? fileName;
  final String? createdAt;
  final RequiredDocumentEntity? requiredDocument;

  DocumentEntity({
    this.id,
    this.message,
    this.fileName,
    this.createdAt,
    this.requiredDocument,
  });

  @override
  List<Object?> get props => [
        id,
        message,
        fileName,
        createdAt,
        requiredDocument,
      ];

  toEntity() => DocumentEntity(
        id: id,
        message: message,
        fileName: fileName,
        createdAt: createdAt,
        requiredDocument: requiredDocument,
      );
}

class RequiredDocumentEntity extends Equatable {
  final int? id;
  final String? fileType;
  final String? fileName;
  final bool? hasExpiration;

  const RequiredDocumentEntity({
    this.id,
    this.fileType,
    this.fileName,
    this.hasExpiration,
  });

  @override
  List<Object?> get props => [
        id,
        fileType,
        fileName,
        hasExpiration,
      ];

  toEntity() => RequiredDocumentEntity(
        id: id,
        fileType: fileType,
        fileName: fileName,
        hasExpiration: hasExpiration,
      );
}
