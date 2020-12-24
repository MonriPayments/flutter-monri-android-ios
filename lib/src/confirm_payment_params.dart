import 'package:MonriPayments/src/payment_method_params.dart';
import 'package:MonriPayments/src/transaction_params.dart';

class ConfirmPaymentParams{
  String paymentId;
  PaymentMethodParams paymentMethod;
  TransactionParams transaction;

  ConfirmPaymentParams.create(this.paymentId, this.paymentMethod, this.transaction);

  Map<String, dynamic> toJson() => {
    "payment_method" : paymentMethod.toJson(),
    "transaction" : transaction.toJson(),
    "paymentId" : paymentId,
  };
}
