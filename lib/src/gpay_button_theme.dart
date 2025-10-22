/// Google Pay button themes
enum GPayButtonTheme {
  light(0),
  dark(1);

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