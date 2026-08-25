class UpdatePartnerDriverStateParams {
  final int applicantId, canViewSettlements;

  UpdatePartnerDriverStateParams({
    required this.applicantId,
    required this.canViewSettlements,
  });

  Map<String, dynamic> toJson() => {
        "applicant_id": applicantId,
        "can_view_settlements": canViewSettlements,
      };
}
