/// A single tire's readings, shared by the trailer and truck inspection flows.
class Tire {
  static const int minSafeDepth = 15;
  static const int minSafePressure = 100;

  String name;
  int pressure;
  int depth;

  /// True once the driver has explicitly confirmed this tire in the editor.
  /// Distinguishes a real reading from the untouched 15/100 default.
  bool checked;

  Tire({
    required this.name,
    required this.pressure,
    required this.depth,
    this.checked = false,
  });

  bool get depthLow => depth < minSafeDepth;
  bool get pressureLow => pressure < minSafePressure;

  /// A tire is flagged when either reading is below the safe threshold.
  bool get isLow => depthLow || pressureLow;
}
