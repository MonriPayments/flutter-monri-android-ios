/// Google Pay button types
enum GPayButtonType {
  pay(0),
  buy(1),
  checkout(2),
  book(3),
  donate(4),
  order(5),
  subscribe(6),
  contribute(7);

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