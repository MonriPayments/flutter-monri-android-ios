import 'dart:convert';

import 'package:MonriPayments/MonriPayments.dart';
import 'package:MonriPayments/src/payment_response.dart';

class MonriPaymentsTest extends MonriPayments {

  @override
  Future<PaymentResponse> confirmPayment(
      CardConfirmPaymentParams params) async {
    return PaymentResponse.fromJson(jsonDecode(_json3));
  }

  @override
  Future<PaymentResponse> savedCardPayment(
      SavedCardConfirmPaymentParams params) async {
    return PaymentResponse.fromJson(jsonDecode(_json3));
  }

  @override
  Future<PaymentResponse> confirmApplePayPayment(ApplePayConfirmPaymentParams arguments) async {
    return PaymentResponse.fromJson(jsonDecode(_json3));
  }

  @override
  Future<PaymentResponse> confirmGooglePayPayment(CardConfirmPaymentParams params) async {
    return PaymentResponse.fromJson(jsonDecode(_json3));
  }
}


String _json1 = """
{
  "status": "result",
  "data": {
    "status": "declined"
  }
}""";
String _json2 = """
{
  "status": "error"
}
""";
String _json3 = """
{
  "status": "result",
  "data": {
    "status": "approved"
  }
}""";

String _json4 = """
{
  "statu": "result"
}
""";
