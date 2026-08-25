import 'package:flutter/material.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';

import '../../modules/shipments/domain/entities/shipment_entity.dart';

/// A completed shipment still awaiting office approval (vs fully closed).
bool _isWaitingApproval(ShipmentEntity shipment) =>
    shipment.driverStatus == 'transit-complete';

enum TripType {
  assigned('assigned'),
  waiting('waiting'),
  transit('transit'),
  completed('completed'),
  rejected('rejected'),
  bolRejected('bol-rejected');

  const TripType(this.type);
  final String type;
}

extension ConvertMessage on String {
  TripType toEnum() {
    switch (this) {
      case 'assigned':
        return TripType.assigned;
      case 'waiting':
        return TripType.waiting;

      case 'transit':
        return TripType.transit;
      case 'completed':
        return TripType.completed;

      case 'rejected':
        return TripType.rejected;
      case 'bol-rejected':
        return TripType.bolRejected;

      default:
        return TripType.assigned;
    }
  }
}

/// Per-[TripType] presentation styling for a shipment row.
extension TripTypeStyle on TripType {
  /// Left status rail color (waiting near-invisible, rejected muted + dashed).
  Color railColor(BuildContext context, ShipmentEntity shipment) {
    switch (this) {
      case TripType.assigned:
        return AppColors.info;
      case TripType.waiting:
        return context.dividerColor;
      case TripType.transit:
        return AppColors.warning;
      case TripType.bolRejected:
        return AppColors.error;
      case TripType.completed:
        return _isWaitingApproval(shipment)
            ? AppColors.info
            : AppColors.success;
      case TripType.rejected:
        return context.hintColor;
    }
  }

  /// Status pill text color (amber/green darkened on light for AA).
  Color pillTextColor(BuildContext context, ShipmentEntity shipment) {
    switch (this) {
      case TripType.assigned:
        return AppColors.info;
      case TripType.waiting:
        return context.secondaryTextColor;
      case TripType.transit:
        return context.warningTextColor;
      case TripType.bolRejected:
        return AppColors.error;
      case TripType.completed:
        return _isWaitingApproval(shipment)
            ? AppColors.info
            : context.successTextColor;
      case TripType.rejected:
        return context.hintColor;
    }
  }

  /// Uppercase status pill label.
  String pillLabel(ShipmentEntity shipment) {
    switch (this) {
      case TripType.assigned:
        return 'NEW LOAD';
      case TripType.waiting:
        return 'WAITING';
      case TripType.transit:
        return 'IN TRANSIT';
      case TripType.bolRejected:
        return 'BOL REJECTED';
      case TripType.completed:
        return _isWaitingApproval(shipment) ? 'WAITING APPROVAL' : 'COMPLETED';
      case TripType.rejected:
        return 'REJECTED';
    }
  }

  /// Glyph for the status icon chip.
  IconData statusIcon(ShipmentEntity shipment) {
    switch (this) {
      case TripType.assigned:
        return Icons.inventory_2_rounded;
      case TripType.waiting:
        return Icons.schedule_rounded;
      case TripType.transit:
        return Icons.local_shipping_rounded;
      case TripType.bolRejected:
        return Icons.assignment_late_rounded;
      case TripType.completed:
        return _isWaitingApproval(shipment)
            ? Icons.pending_rounded
            : Icons.check_circle_rounded;
      case TripType.rejected:
        return Icons.cancel_rounded;
    }
  }

  /// Actionable states carry a CTA button; passive states show only the pill.
  bool get hasActionButton =>
      this == TripType.assigned ||
      this == TripType.transit ||
      this == TripType.bolRejected;

  /// Archived states (rejected) get a dashed rail to read apart from active ones.
  bool get railDashed => this == TripType.rejected;

  /// Row dim — archived states are muted; everything else is full opacity.
  double get rowOpacity => this == TripType.rejected ? .70 : 1.0;

  /// Card surface — error-tinted for BOL-rejected, the plain card otherwise.
  Color cardFill(BuildContext context) => this == TripType.bolRejected
      ? context.errorSurfaceColor
      : context.cardColor;

  /// Card border — emphasized accent for urgent states, divider for the rest.
  Color cardBorderColor(BuildContext context) {
    switch (this) {
      case TripType.bolRejected:
        return AppColors.error.applyOpacity(.45);
      case TripType.transit:
        return AppColors.warning.applyOpacity(.40);
      default:
        return context.dividerColor;
    }
  }

  /// Single status accent — rail, chips, borders, pill tint, ticks, buttons.
  Color accentColor(BuildContext context) {
    switch (this) {
      case TripType.assigned:
        return AppColors.info;
      case TripType.transit:
        return AppColors.warning;
      case TripType.completed:
        return AppColors.success;
      case TripType.bolRejected:
        return AppColors.error;
      case TripType.waiting:
      case TripType.rejected:
        return context.hintColor;
    }
  }
}
