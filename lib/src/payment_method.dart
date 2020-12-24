
import 'package:MonriPayments/src/payment_method_params.dart';

abstract class PaymentMethod {
  static final String TYPE_CARD = "card";
  static final String TYPE_SAVED_CARD = "saved_card";

  String paymentMethodType();

  Map<String, String> data();

  PaymentMethodParams toPaymentMethodParams() => PaymentMethodParams.init(paymentMethodType(), data());
}
