/// Google Pay button themes
enum GPayButtonTheme {
  dark(1),
  light(2);

  final int rawValue;
  const GPayButtonTheme(this.rawValue);

  static GPayButtonTheme? fromRawValue(int rawValue) {
    try {
      return GPayButtonTheme.values.firstWhere((e) => e.rawValue == rawValue);
    } catch (_) {
      return null;
    }
  }
}