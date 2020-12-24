import 'package:MonriPayments/MonriPayments.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var payment = MonriPayments.createTest();
  test("payment test", () async {
    // var paymentResponse = await payment.confirmPayment({});
    // print(paymentResponse);
  });
}
