abstract final class AmountFormatter {
  /// Rounds to 2 decimal places, returns double.
  static double round2(double amount) =>
      double.parse(amount.toStringAsFixed(2));

  /// Rounds to 2 decimal places, returns string.
  static String format(double amount) => amount.toStringAsFixed(2);

  /// Rounds keeping full precision up to 2 significant decimal places.
  static double roundPrecise(double amount) {
    final s = amount.toStringAsFixed(20);
    return double.parse(s.substring(0, s.length - 18));
  }

  /// Returns the precise value as a string (2 significant decimal places).
  static String formatPrecise(double amount) {
    final s = amount.toStringAsFixed(20);
    return s.substring(0, s.length - 18);
  }
}
