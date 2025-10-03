/// Dart equivalent of PKPaymentButtonStyle (with raw values)
enum PKPaymentButtonStyle {
  white(0),
  whiteOutline(1),
  black(2),
  automatic(3); // iOS 14.0+

  final int rawValue;
  const PKPaymentButtonStyle(this.rawValue);

  static PKPaymentButtonStyle? fromRawValue(int rawValue) {
    try {
      return PKPaymentButtonStyle.values
          .firstWhere((e) => e.rawValue == rawValue);
    } catch (_) {
      return null;
    }
  }
}
