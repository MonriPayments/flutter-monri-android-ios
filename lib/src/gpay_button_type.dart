/// Google Pay button types
enum GPayButtonType {
  buy(1),
  book(2),
  checkout(3),
  donate(4),
  order(5),
  pay(6),
  subscribe(7),
  plain(8),
  pix(9),
  ewallet(10);

  final int rawValue;
  const GPayButtonType(this.rawValue);

  static GPayButtonType? fromRawValue(int rawValue) {
    try {
      return GPayButtonType.values.firstWhere((e) => e.rawValue == rawValue);
    } catch (_) {
      return null;
    }
  }
}