
import 'package:MonriPayments/src/payment_method_params.dart';

abstract class PaymentMethod {
  static final String TYPE_CARD = "card";
  static final String TYPE_SAVED_CARD = "saved_card";
  static final String APPLE_PAY = "apple-pay";
  static final String GOOGLE_PAY = "google-pay";

  String paymentMethodType();

  Map<String, String> data();

  PaymentMethodParams toPaymentMethodParams() => PaymentMethodParams(paymentMethodType(), data());
}
