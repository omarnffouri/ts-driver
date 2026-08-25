import 'package:equatable/equatable.dart';

class ApplicantStateEntity extends Equatable {
  final String? applicantStatus;
  final DateTime? createdAt;
  final String? profileCompletion;
  final bool? hasSeenAllVideos;
  final String? truck;
  final String? totalEarnings;
  final String? totalTrips;
  final String? lastSettlement;
  final int? pendingDocumentRequests;
  final int? unsignedForms;

  const ApplicantStateEntity({
    this.applicantStatus,
    this.createdAt,
    this.profileCompletion,
    this.hasSeenAllVideos,
    this.truck,
    this.totalEarnings,
    this.totalTrips,
    this.lastSettlement,
    this.pendingDocumentRequests,
    this.unsignedForms,
  });

  /// Identity fields (mobile / SSN) become read-only once the applicant has
  /// been hired or approved. Single source of truth for Profile & Settings.
  bool get isEditingLocked =>
      applicantStatus == 'hired' || applicantStatus == 'approved';

  @override
  List<Object?> get props => [
        applicantStatus,
        createdAt,
        profileCompletion,
        hasSeenAllVideos,
        truck,
        totalEarnings,
        totalTrips,
        lastSettlement,
        pendingDocumentRequests,
        unsignedForms,
      ];
}
