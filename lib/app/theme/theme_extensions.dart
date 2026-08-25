import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

/// Theme-aware color accessors off [BuildContext].
///
/// This is the ONLY place the `isDark ? darkX : lightX` ternary is written.
/// Call sites use `context.panelColor`, `context.primaryTextColor`, etc., so
/// they stay agnostic to the active theme and never branch on brightness.
extension ContextColorExtensions on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Scaffold / page background.
  Color get backgroundColor =>
      isDark ? AppColors.darkBackground : AppColors.lightBackground;

  /// Elevated surfaces: app bars, dialogs.
  Color get panelColor =>
      isDark ? AppColors.darkSurface : AppColors.lightSurface;

  /// Bottom-sheet surface (light = page grey so white cards read elevated).
  Color get sheetColor =>
      isDark ? AppColors.darkSurface : AppColors.lightBackground;

  /// Soft card elevation — light only (dark uses the luminance step + border).
  List<BoxShadow>? get cardShadow => isDark
      ? null
      : [
          BoxShadow(
            color: const Color(0x1F3E4958),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
            spreadRadius: -4.r,
          ),
        ];

  /// Upward drop shadow for a pinned bottom action bar (light only; in dark the
  /// top hairline border alone separates it — shadows are invisible there).
  List<BoxShadow>? get bottomBarShadow => isDark
      ? null
      : [
          BoxShadow(
            color: const Color(0x14000000),
            blurRadius: 12.r,
            offset: Offset(0, -3.h),
          ),
        ];

  /// Card containers.
  Color get cardColor => isDark ? AppColors.darkCard : AppColors.lightCard;

  /// List rows / tiles.
  Color get tileColor => isDark ? AppColors.darkTile : AppColors.lightTile;

  /// Recessed form-field fill sitting on a card (soft recess in light, a step
  /// above the card in dark).
  Color get inputFillColor =>
      isDark ? AppColors.darkInputFill : AppColors.lightInputFill;

  /// Primary (high-emphasis) text.
  Color get primaryTextColor =>
      isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

  /// Maximum-contrast title text — pure black in light, off-white in dark.
  /// Use for list/row titles that should read crisper than [primaryTextColor].
  Color get strongTextColor =>
      isDark ? AppColors.darkTextPrimary : Colors.black;

  /// Secondary (medium-emphasis) text.
  Color get secondaryTextColor =>
      isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

  /// Hints / placeholders / disabled text.
  Color get hintColor => isDark ? AppColors.darkHint : AppColors.lightHint;

  /// Dividers / hairline borders.
  Color get dividerColor =>
      isDark ? AppColors.darkDivider : AppColors.lightDivider;

  /// Loading-skeleton resting tone.
  Color get shimmerBaseColor =>
      isDark ? AppColors.darkShimmerBase : AppColors.lightShimmerBase;

  /// Loading-skeleton sweeping band.
  Color get shimmerHighlightColor =>
      isDark ? AppColors.darkShimmerHighlight : AppColors.lightShimmerHighlight;

  /// Amber legible as text (darkened on light, full-strength on dark).
  Color get warningTextColor =>
      isDark ? AppColors.warning : AppColors.warningDeep;

  /// Green legible as text (darkened on light, full-strength on dark).
  Color get successTextColor =>
      isDark ? AppColors.success : const Color(0xFF1E8E4E);

  /// Background alpha for a status tint pill / icon chip.
  double statusTintAlpha({required bool isTransit}) =>
      isDark ? (isTransit ? .22 : .20) : (isTransit ? .16 : .14);

  /// Brand-red wash for chips / badges sitting on a card surface.
  Color get primaryTint =>
      AppColors.primary.withValues(alpha: isDark ? .18 : .12);

  /// Error-tinted card surface for urgent (BOL-rejected) shipments.
  Color get errorSurfaceColor => Color.alphaBlend(
        AppColors.error.withValues(alpha: isDark ? .16 : .10),
        cardColor,
      );

  /// Amber-tinted surface for non-status warning strips (e.g. Total Mileage).
  Color get warningSurfaceColor =>
      AppColors.warning.withValues(alpha: isDark ? .20 : .14);

  /// Header gradient: brand red in light, a near-black → dark-red sweep in dark.
  Gradient get headerGradient =>
      isDark ? AppColors.darkHeaderGradient : AppColors.brandHeaderGradient;

  /// Text painted on the brand header — on-primary white on the bright red
  /// (light), off-white in dark so it doesn't glare against the near-black sweep.
  Color get onHeaderTextColor =>
      isDark ? AppColors.darkTextPrimary : AppColors.onPrimary;

  /// Muted counterpart of [onHeaderTextColor] for secondary header text
  /// (unselected tab labels, quiet counts).
  Color get onHeaderMutedTextColor => isDark
      ? Colors.white.withValues(alpha: .55)
      : Colors.white.withValues(alpha: .78);

  // ── Frosted segmented tabs (sit on the red header) ─────────────────────
  // Track — a faint white frost over the header in both modes, hairline border.
  Color get segmentedTrackColor =>
      isDark ? Colors.white12 : Colors.white.withValues(alpha: .15);
  Color get segmentedTrackBorderColor =>
      isDark ? Colors.white10 : Colors.white.withValues(alpha: .20);
  // Selected pill — light: a solid white pill + red label. Dark: NO pill fill;
  // selection is carried by the bold white label (and the red count badge).
  Color get segmentedSelectedColor =>
      isDark ? Colors.transparent : Colors.white;
  Color get segmentedSelectedLabelColor =>
      isDark ? AppColors.onPrimary : AppColors.primary;
  Color get segmentedUnselectedLabelColor => onHeaderMutedTextColor;
  List<BoxShadow>? get segmentedSelectedShadow => isDark
      ? null
      : const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ];

  // ── Header stepper (forms) ──────────────────────────────────────────────
  // Step pills sit on the red header like the segmented tabs: solid white in
  // light, a quiet frost + off-white number in dark so the row doesn't glare.
  Color get stepPillColor => isDark ? Colors.white12 : Colors.white;
  Color get stepPillTextColor =>
      isDark ? AppColors.darkTextPrimary : AppColors.primary;
  Color get stepConnectorColor => isDark ? Colors.white38 : Colors.white;

  /// Conversation-list surface — one elevation step above the scaffold so the
  /// dark sheet reads "dark but alive". Scoped to chat; not the global bg.
  Color get chatListBackground => isDark
      ? AppColors.darkChatListBackground
      : AppColors.lightChatListBackground;

  /// Muted grey for chat message previews and timestamps (same both modes).
  Color get chatPreviewColor => AppColors.chatPreviewGrey;

  /// Offline presence dot.
  Color get offlineDotColor =>
      isDark ? AppColors.darkOfflineDot : AppColors.lightOfflineDot;

  // ── Chat detail (conversation thread) ──────────────────────────────────

  /// Received (incoming) bubble surface.
  Color get receivedBubbleColor =>
      isDark ? AppColors.darkReceivedBubble : AppColors.lightReceivedBubble;

  /// Text / icons painted on a received bubble.
  Color get receivedBubbleTextColor => isDark
      ? AppColors.darkReceivedBubbleText
      : AppColors.lightReceivedBubbleText;

  /// Sent (outgoing) bubble surface — brand red (text uses AppColors.onPrimary).
  Color get sentBubbleColor => AppColors.sentBubble;

  /// Chat input pill surface.
  Color get chatInputSurfaceColor =>
      isDark ? AppColors.darkChatInputSurface : AppColors.lightChatInputSurface;

  /// Chat input pill drop-shadow colour (transparent in dark).
  Color get chatInputShadowColor =>
      isDark ? AppColors.darkChatInputShadow : AppColors.lightChatInputShadow;

  /// Message-list canvas behind the chat pattern (not the global scaffold bg).
  Color get chatCanvasColor =>
      isDark ? AppColors.darkChatCanvas : AppColors.lightChatCanvas;

  /// Neutral app-bar action icon (selection-mode copy).
  Color get chatAppBarIconColor =>
      isDark ? AppColors.darkChatAppBarIcon : AppColors.lightChatAppBarIcon;

  /// Read-receipt ticks on a received bubble (sent ticks use onPrimary).
  Color get receiptTickColor =>
      isDark ? AppColors.darkReceiptTick : AppColors.lightReceiptTick;

  /// Reaction chip surface floating above a bubble.
  Color get reactionChipColor =>
      isDark ? AppColors.darkReactionChip : AppColors.lightReactionChip;

  /// Signature writing panel — light with black ink in light mode, a dark
  /// recessed surface with off-white ink in dark. Display only: the exported
  /// PNG is always re-inked black-on-light (legal signature) by the controller.
  Color get signaturePanelColor =>
      isDark ? AppColors.darkSignaturePanel : AppColors.lightSignaturePanel;

  /// Decorative illustrations drawn for light backgrounds — dimmed in dark so
  /// their baked-in white shapes don't glare against the near-black scaffold.
  double get illustrationOpacity => isDark ? .8 : 1;
}
