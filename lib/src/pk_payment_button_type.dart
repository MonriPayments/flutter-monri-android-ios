/// Dart equivalent of PKPaymentButtonType (with raw values)
enum PKPaymentButtonType {
  plain(0),
  buy(1),
  setUp(2),       // iOS 9.0+
  inStore(3),     // iOS 10.0+
  donate(4),      // iOS 10.2+
  checkout(5),    // iOS 12.0+
  book(6),        // iOS 12.0+
  subscribe(7),   // iOS 12.0+
  reload(8),      // iOS 14.0+
  addMoney(9),    // iOS 14.0+
  topUp(10),      // iOS 14.0+
  order(11),      // iOS 14.0+
  rent(12),       // iOS 14.0+
  support(13),    // iOS 14.0+
  contribute(14), // iOS 14.0+
  tip(15),        // iOS 14.0+
  continue_(16);  // iOS 15.0+

  final int rawValue;
  const PKPaymentButtonType(this.rawValue);

  static PKPaymentButtonType? fromRawValue(int rawValue) {
    try {
      return PKPaymentButtonType.values
          .firstWhere((e) => e.rawValue == rawValue);
    } catch (_) {
      return null;
    }
  }
}
