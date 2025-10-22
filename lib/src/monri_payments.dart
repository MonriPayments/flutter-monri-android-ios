import 'dart:async';
import 'package:MonriPayments/MonriPayments.dart';
import 'package:MonriPayments/src/gpay_button_theme.dart';
import 'package:MonriPayments/src/gpay_button_type.dart';
import 'package:MonriPayments/src/pk_payment_button_style.dart';
import 'package:MonriPayments/src/pk_payment_button_type.dart';
import 'package:MonriPayments/src/test/monri_payments_test.dart';
import 'package:flutter/services.dart';

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
  final String? applePayMerchantID;

  CardConfirmPaymentParams(
      {required this.authenticityToken,
      required this.clientSecret,
      required this.cardNumber,
      required this.cvv,
      required this.expiryYear,
      required this.expiryMonth,
      required this.transactionParams,
      required this.isDebug,
      required this.tokenizePan,
      required this.applePayMerchantID});

  Map<String, dynamic> toJSON() {
    return {
      "authenticity_token": authenticityToken,
      "applePayMerchantID": applePayMerchantID,
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
    if (!json.containsKey("authenticity_token")) {
      throw "CardConfirmPaymentParams::fromJson method doesn't have a key: ${1}";
    }

    TransactionParams trxParams = TransactionParams.create();
    Map<String, String> tmpData =
        Map<String, String>.from(json["transaction_params"]);
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
        tokenizePan: json["card"]["tokenize_pan"] ?? false,
        applePayMerchantID: json["applePayMerchantID"]);
  }
}

class ApplePayConfirmPaymentParams {
  final String authenticityToken;
  final String clientSecret;
  final TransactionParams? transactionParams;
  final bool isDebug;
  final String? applePayMerchantID;
  final PKPaymentButtonStyle? pkPaymentButtonStyle;
  final PKPaymentButtonType? pkPaymentButtonType;

  ApplePayConfirmPaymentParams(
      {required this.authenticityToken,
        required this.clientSecret,
        required this.transactionParams,
        required this.isDebug,
        required this.applePayMerchantID,
        required this.pkPaymentButtonStyle,
        required this.pkPaymentButtonType});

  Map<String, dynamic> toJSON() {
    return {
      "authenticity_token": authenticityToken,
      "applePayMerchantID": applePayMerchantID,
      "client_secret": clientSecret,
      "is_development_mode": isDebug,
      "transaction_params": transactionParams?.toJson() ?? {},
      "pkPaymentButtonStyle" : pkPaymentButtonStyle?.rawValue ?? null,
      "pkPaymentButtonType" : pkPaymentButtonType?.rawValue ?? null
    };
  }

  static ApplePayConfirmPaymentParams fromJSON(Map<String, dynamic> json) {
    if (!json.containsKey("authenticity_token")) {
      throw "ApplePayConfirmPaymentParams::fromJson method doesn't have a key: ${1}";
    }

    TransactionParams trxParams = TransactionParams.create();
    Map<String, String> tmpData =
    Map<String, String>.from(json["transaction_params"]);
    trxParams.data = tmpData;

    var style = json["pkPaymentButtonStyle"] != null ? PKPaymentButtonStyle.fromRawValue(json["pkPaymentButtonStyle"]) : PKPaymentButtonStyle.black;
    var type = json["pkPaymentButtonType"] != null ? PKPaymentButtonType.fromRawValue(json["pkPaymentButtonType"]) : PKPaymentButtonType.buy;

    return ApplePayConfirmPaymentParams(
        authenticityToken: json["authenticity_token"],
        clientSecret: json["client_secret"],
        transactionParams: trxParams,
        isDebug: json["is_development_mode"],
        applePayMerchantID: json["applePayMerchantID"],
        pkPaymentButtonStyle: style,
        pkPaymentButtonType: type);
  }
}

class GooglePayConfirmPaymentParams {
  final String authenticityToken;
  final String clientSecret;
  final TransactionParams? transactionParams;
  final bool isDebug;
  final GPayButtonType? gPayButtonType;
  final GPayButtonTheme? gPayButtonTheme;

  GooglePayConfirmPaymentParams(
      {required this.authenticityToken,
        required this.clientSecret,
        required this.transactionParams,
        required this.isDebug,
        required this.gPayButtonTheme,
        required this.gPayButtonType
      });

  Map<String, dynamic> toJSON() {
    return {
      "authenticity_token": authenticityToken,
      "client_secret": clientSecret,
      "is_development_mode": isDebug,
      "transaction_params": transactionParams?.toJson() ?? {},
      "gPayButtonType": gPayButtonType?.rawValue ?? null,
      "gPayButtonTheme": gPayButtonTheme?.rawValue ?? null
    };
  }

  static GooglePayConfirmPaymentParams fromJSON(Map<String, dynamic> json) {
    if (!json.containsKey("authenticity_token")) {
      throw "GooglePayConfirmPaymentParams::fromJson method doesn't have a key: ${1}";
    }

    TransactionParams trxParams = TransactionParams.create();
    Map<String, String> tmpData =
    Map<String, String>.from(json["transaction_params"]);
    trxParams.data = tmpData;

    return GooglePayConfirmPaymentParams(
        authenticityToken: json["authenticity_token"],
        clientSecret: json["client_secret"],
        transactionParams: trxParams,
        isDebug: json["is_development_mode"],
    gPayButtonTheme: json[""],
    gPayButtonType: json[""]);
  }
}

class SavedCardConfirmPaymentParams {
  final String authenticityToken;
  final String clientSecret;
  final String panToken;
  final String? cvv;
  final TransactionParams transactionParams;
  final bool isDebug;

  SavedCardConfirmPaymentParams({
    required this.authenticityToken,
    required this.clientSecret,
    required this.panToken,
    required this.cvv,
    required this.transactionParams,
    required this.isDebug,
  });

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

  static SavedCardConfirmPaymentParams fromJSON(Map<String, dynamic> json) {
    //todo do we need this method
    // TODO some validation?
    if (!json.containsKey("authenticity_token")) {
      throw "CardConfirmPaymentParams::fromJson method doesn't have a key: ${1}";
    }

    TransactionParams trxParams = TransactionParams.create();
    Map<String, dynamic> tmpData = json["transaction_params"];
    trxParams.data = tmpData;
    Map<String, dynamic> card = json["card"];

    return SavedCardConfirmPaymentParams(
      authenticityToken: json["authenticity_token"],
      clientSecret: json["client_secret"],
      panToken: card["pan_token"],
      cvv: card.containsKey("cvv") ? card["cvv"] : null,
      transactionParams: trxParams,
      isDebug: json["is_development_mode"],
    );
  }
}

class _MonriPaymentsImpl extends MonriPayments {
  static const MethodChannel _channel = const MethodChannel('MonriPayments');

  @override
  Future<PaymentResponse> confirmPayment(
      CardConfirmPaymentParams arguments) async {
    Map result =
        await _channel.invokeMethod('confirmPayment', arguments.toJSON());
    return PaymentResponse.fromJson(result);
  }

  @override
  Future<PaymentResponse> savedCardPayment(
      SavedCardConfirmPaymentParams arguments) async {
    Map result =
        await _channel.invokeMethod('confirmPayment', arguments.toJSON());
    // print(result);
    return PaymentResponse.fromJson(result);
  }

  @override
  Future<PaymentResponse> confirmApplePayPayment(ApplePayConfirmPaymentParams arguments) async {
    Map result =
        await _channel.invokeMethod('confirmApplePayment', arguments.toJSON());
    // print(result);
    return PaymentResponse.fromJson(result);
  }

  @override
  Future<PaymentResponse> confirmGooglePayPayment(GooglePayConfirmPaymentParams arguments) async {
    Map result =
        await _channel.invokeMethod('confirmGooglePayment', arguments.toJSON());
    // print(result);
    return PaymentResponse.fromJson(result);
  }
}

abstract class MonriPayments {
  static MonriPayments create() => _MonriPaymentsImpl();

  static MonriPayments createTest() => MonriPaymentsTest();

  Future<PaymentResponse> confirmPayment(CardConfirmPaymentParams params);

  Future<PaymentResponse> savedCardPayment(
      SavedCardConfirmPaymentParams params);

  Future<PaymentResponse> confirmApplePayPayment(ApplePayConfirmPaymentParams arguments);

  Future<PaymentResponse> confirmGooglePayPayment(GooglePayConfirmPaymentParams params);
}
