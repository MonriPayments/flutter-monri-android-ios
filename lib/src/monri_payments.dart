import 'dart:async';
import 'package:MonriPayments/MonriPayments.dart';
import 'package:MonriPayments/src/payment_response.dart';
import 'package:MonriPayments/src/test/monri_payments_test.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class CardConfirmPaymentParams {
  final String authenticityToken;
  final String clientSecret;
  final String cardNumber;
  final String cvv;
  final int expiryYear;
  final int expiryMonth;
  final TransactionParams? transactionParams;
  final bool isDebug;
  final bool tokenizePan;

  CardConfirmPaymentParams({
    required this.authenticityToken,
    required this.clientSecret,
    required this.cardNumber,
    required this.cvv,
    required this.expiryYear,
    required this.expiryMonth,
    required this.transactionParams,
    required this.isDebug,
    required this.tokenizePan,
  });

  Map<String, dynamic> toJSON() {
    return {
      "authenticity_token": authenticityToken,
      "card": {
        "pan": cardNumber,
        "expiry_year": expiryYear,
        "expiry_month": expiryMonth,
        "cvv": cvv,
        "tokenize_pan": tokenizePan
      },
      "client_secret": clientSecret,
      "is_development_mode": isDebug,
      "transaction_params": transactionParams?.toJson() ?? {}
    };
  }

  static CardConfirmPaymentParams fromJSON(Map<String, dynamic> json) {
    // todo do we need this method
    //todo some validation?
    if (!json.containsKey("authenticity_token")){
      throw "CardConfirmPaymentParams::fromJson method doesn't have a key: ${1}";
    }

    TransactionParams trxParams = TransactionParams.create();
    Map<String, String> tmpData = Map<String, String>.from(json["transaction_params"]);
    trxParams.data = tmpData;

    return CardConfirmPaymentParams(
        authenticityToken: json["authenticity_token"],
        clientSecret: json["client_secret"],
        cardNumber: json["card"]["pan"],
        cvv: json["card"]["cvv"],
        expiryYear: int.parse(json["card"]["expiryYear"]),
        expiryMonth: int.parse(json["card"]["expiryMonth"]),
        transactionParams: trxParams,
        isDebug: json["is_development_mode"],
        tokenizePan: json["card"]["tokenize_pan"] ?? false
    );
  }

}

class SavedCardConfirmPaymentParams {
  final String authenticityToken;
  final String clientSecret;
  final String panToken;
  final String cvv;
  final TransactionParams transactionParams;
  final bool isDebug;


  SavedCardConfirmPaymentParams({
    required this.authenticityToken,
    required this.clientSecret,
    required this.panToken,
    required this.cvv,
    required this.transactionParams,
    required this.isDebug});

  Map<String, dynamic> toJSON() {
    return {
      "authenticity_token": authenticityToken,
      "saved_card": {
        "pan_token": panToken,
        "cvv": cvv,
      },
      "client_secret": clientSecret,
      "is_development_mode": isDebug,
      "transaction_params": transactionParams.toJson()
    };
  }
}

class _MonriPaymentsImpl extends MonriPayments {
  static const MethodChannel _channel = const MethodChannel('MonriPayments');

  Future<PaymentResponse> confirmPayment(
      CardConfirmPaymentParams arguments) async {
    Map result = await _channel.invokeMethod('confirmPayment', arguments.toJSON());
    return PaymentResponse.fromJson(result);
  }

  Future<PaymentResponse> savedCardPayment(
      SavedCardConfirmPaymentParams arguments) async {
    Map result = await _channel.invokeMethod('confirmPayment', arguments.toJSON());
    // print(result);
    return PaymentResponse.fromJson(result);
  }
//confirmPayment
}

abstract class MonriPayments {
  static MonriPayments create() => _MonriPaymentsImpl();

  static MonriPayments createTest() => MonriPaymentsTest();

  Future<PaymentResponse> confirmPayment(CardConfirmPaymentParams params);

  Future<PaymentResponse> savedCardPayment(
      SavedCardConfirmPaymentParams params);
}
