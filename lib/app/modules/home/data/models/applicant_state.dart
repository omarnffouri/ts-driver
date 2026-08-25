import '../../domain/entities/applicant_state_entity.dart';

class ApplicantState extends ApplicantStateEntity {
  const ApplicantState({
    super.applicantStatus,
    super.createdAt,
    super.profileCompletion,
    super.hasSeenAllVideos,
    super.truck,
    super.totalEarnings,
    super.totalTrips,
    super.lastSettlement,
    super.pendingDocumentRequests,
    super.unsignedForms,
  });

  factory ApplicantState.fromJson(Map<String, dynamic> json) => ApplicantState(
        applicantStatus: json["status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        profileCompletion: json["signing_percentage"],
        hasSeenAllVideos: json["has_seen_videos"] == 0 ? false : true,
        truck: json["truck"].toString(),
        totalEarnings: json["total_earning"] == null
            ? "0"
            : json["total_earning"].toString(),
        totalTrips:
            json["total_trips"] == null ? "0" : json["total_trips"].toString(),
        lastSettlement: json["last_settlement_amount"] == null
            ? "0"
            : json["last_settlement_amount"].toString(),
        pendingDocumentRequests:
            int.tryParse("${json["pending_document_requests"] ?? 0}") ?? 0,
        unsignedForms: int.tryParse("${json["unsigned_forms"] ?? 0}") ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "status": applicantStatus,
        "created_at": createdAt?.toIso8601String(),
        "signing_percentage": profileCompletion,
        "has_seen_videos": hasSeenAllVideos,
        "truck": truck,
        "total_earning": totalEarnings,
        "total_trips": totalTrips,
        "last_settlement_amount": lastSettlement,
        "pending_document_requests": pendingDocumentRequests,
        "unsigned_forms": unsignedForms,
      };
}
