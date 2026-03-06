import 'dart:convert';

import 'package:MonriPayments/MonriPayments.dart';
import 'package:MonriPayments/src/payment_response.dart';
import 'package:MonriPayments/src/scandoc/scan_doc_api_options.dart';
import 'package:MonriPayments/src/scandoc/scan_doc_extraction_configuration.dart';
import 'package:MonriPayments/src/scandoc/scan_doc_extraction_response.dart';
import 'package:MonriPayments/src/scandoc/scan_doc_validation_configuration.dart';
import 'package:MonriPayments/src/scandoc/scan_doc_validation_response.dart';

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
  Future<PaymentResponse> confirmGooglePayPayment(GooglePayConfirmPaymentParams params) async {
    return PaymentResponse.fromJson(jsonDecode(_json3));
  }

  @override
  Future<ScanDocExtractionResponse?> extractScannedCard(String base64Image, ScanDocExtractionConfiguration? configuration) {
    // TODO: implement extractScannedCard
    throw UnimplementedError();
  }

  @override
  Future<void> initScanDoc(ScanDocApiOptions apiOptions) {
    // TODO: implement initScanDoc
    throw UnimplementedError();
  }

  @override
  Future<ScanDocValidationResponse?> validateScannedCard(List<String> base64Images, ScanDocValidationConfiguration? configuration) {
    // TODO: implement validateScannedCard
    throw UnimplementedError();
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
