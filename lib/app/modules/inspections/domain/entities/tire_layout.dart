/// Pure description of a vehicle's tire arrangement: a list of axles, each with
/// a left and right group of one or two tires (single or dual wheels). Slots
/// reference the inspection's tires by index into its tire list; display labels
/// are derived in the presentation layer so this stays framework-agnostic.
enum AxleSide { left, right }

class TireSlot {
  const TireSlot({
    required this.tireIndex,
    required this.side,
    this.isDual = false,
    this.isInner = false,
  });

  /// Index into the inspection's flat tire list.
  final int tireIndex;
  final AxleSide side;

  /// True when this side of the axle carries two stacked tires.
  final bool isDual;

  /// For duals: false = outer, true = inner.
  final bool isInner;
}

class AxleConfig {
  const AxleConfig({
    required this.name,
    required this.left,
    required this.right,
  });

  final String name;
  final List<TireSlot> left;
  final List<TireSlot> right;
}

class TireLayout {
  const TireLayout(this.axles);

  final List<AxleConfig> axles;

  /// Flat, editor-ordered slots: each axle's left tires then its right tires.
  List<TireSlot> get slots => [
        for (final axle in axles) ...[...axle.left, ...axle.right],
      ];
}
