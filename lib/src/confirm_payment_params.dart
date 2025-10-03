import 'package:MonriPayments/src/pk_payment_button_style.dart';
import 'package:MonriPayments/src/pk_payment_button_type.dart';
import 'package:MonriPayments/src/payment_method_params.dart';
import 'package:MonriPayments/src/transaction_params.dart';

class ConfirmPaymentParams{
  String paymentId;
  PaymentMethodParams paymentMethod;
  TransactionParams transaction;
  PKPaymentButtonType? pkPaymentButtonType = null;
  PKPaymentButtonStyle? pkPaymentButtonStyle = null;

  ConfirmPaymentParams.create(this.paymentId, this.paymentMethod, this.transaction);
  ConfirmPaymentParams.createWithApplePayCustomisation(this.paymentId, this.paymentMethod, this.transaction, this.pkPaymentButtonType, this.pkPaymentButtonStyle);

  Map<String, dynamic> toJson() => {
    "payment_method" : paymentMethod.toJson(),
    "transaction" : transaction.toJson(),
    "paymentId" : paymentId,
    "pkPaymentButtonType" : pkPaymentButtonType?.rawValue,
    "pkPaymentButtonStyle" : pkPaymentButtonStyle?.rawValue,
  };
}
