import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../../theme/app_colors.dart';
import '../../../domain/entities/notification_entity.dart';

// Compiled once and reused (these getters run per list item, per frame).
final RegExp _htmlTag = RegExp(r'<[^>]*>');
final RegExp _whitespace = RegExp(r'\s+');

/// Presentation helpers for a [NotificationEntity].
///
/// The status (Hired / On-Hold / …) lives inside the free-text message rather
/// than a structured field, so the accent + icon are derived from keywords.
/// Also strips any HTML the API sends in the body and formats a relative time.
extension NotificationVisuals on NotificationEntity {
  bool get isUnread => read != 1;

  bool get hasImage => image != null && image!.trim().isNotEmpty;

  /// Message with HTML tags stripped and whitespace collapsed.
  String get preview => (message ?? '')
      .replaceAll(_htmlTag, ' ')
      .replaceAll(_whitespace, ' ')
      .trim();

  /// e.g. "2 days ago".
  String get relativeTime =>
      createdAt == null ? '' : timeago.format(createdAt!);

  _NotiKind get _kind {
    final t = '${title ?? ''} ${message ?? ''}'.toLowerCase();
    if (t.contains('reject') ||
        t.contains('declin') ||
        t.contains('denied') ||
        t.contains('suspend') ||
        t.contains('terminat') ||
        t.contains('fail')) {
      return _NotiKind.danger;
    }
    if (t.contains('hold') ||
        t.contains('pending') ||
        t.contains('review') ||
        t.contains('waiting')) {
      return _NotiKind.warning;
    }
    if (t.contains('hired') ||
        t.contains('approve') ||
        t.contains('active') ||
        t.contains('accept') ||
        t.contains('complete')) {
      return _NotiKind.success;
    }
    return _NotiKind.info;
  }

  Color get accentColor => switch (_kind) {
        _NotiKind.success => AppColors.success,
        _NotiKind.warning => AppColors.warning,
        _NotiKind.danger => AppColors.error,
        _NotiKind.info => AppColors.primary,
      };

  IconData get accentIcon {
    if (hasImage) return Icons.campaign_rounded;
    return switch (_kind) {
      _NotiKind.success => Icons.check_circle_rounded,
      _NotiKind.warning => Icons.hourglass_bottom_rounded,
      _NotiKind.danger => Icons.cancel_rounded,
      _NotiKind.info => Icons.notifications_rounded,
    };
  }
}

enum _NotiKind { success, warning, danger, info }
