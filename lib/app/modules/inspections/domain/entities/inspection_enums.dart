/// Shared inspection value types used by both the trailer and truck flows.

class FuelStatus {
  static const List<String> status = [
    empty,
    oneEight,
    oneFour,
    threeEight,
    oneTwo,
    fiveEight,
    threeFour,
    sevenEight,
    full
  ];
  static const String empty = "Empty";
  static const String oneEight = "1 / 8";
  static const String oneFour = "1 / 4";
  static const String threeEight = "3 / 8";
  static const String oneTwo = "1 / 2";
  static const String fiveEight = "5 / 8";
  static const String threeFour = "3 / 4";
  static const String sevenEight = "7 / 8";
  static const String full = "Full";
}

enum OilStatus { low, full }

/// Server-side keys for the five damage sides (shared by truck and trailer).
class TruckSides {
  static const String left = "left";
  static const String right = "right";
  static const String front = "front";
  static const String back = "back";
  static const String inside = "inside";
}
