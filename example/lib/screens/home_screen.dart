import 'dart:convert';
import 'dart:io';

import 'package:MonriPayments/MonriPayments.dart';
import 'package:MonriPayments_example/models/object_argument.dart';
import 'package:MonriPayments_example/widgets/monri_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../routes.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    var platformPayment = Platform.isAndroid ? "Google Pay" : "Apple Pay";

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Monri Flutter Plugin example app'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(10),
          child: ListView(
            children: [
              MonriButton(() {
                    Navigator.pushNamed(
                        context, AvailableAppRoutes.NEW_PAYMENT,
                        arguments: {'req_arg': ObjectArgument(false, false)}
                        );
                  },
                  'new payment'
              ),
              MonriButton(() {
                    Navigator.pushNamed(
                        context, AvailableAppRoutes.NEW_PAYMENT,
                        arguments: {'req_arg': ObjectArgument(true, false)}
                    );
                  },
                  'new payment save card'
              ),
              MonriButton(() {
                Navigator.pushNamed(
                    context, AvailableAppRoutes.NEW_PAYMENT,
                    arguments: {'req_arg': ObjectArgument(false, true)}
                );
              },
                  'new payment 3DS'
              ),
              MonriButton(() {
                Navigator.pushNamed(
                    context, AvailableAppRoutes.NEW_PAYMENT,
                    arguments: {'req_arg': ObjectArgument(true, true)}
                );
              },
                  'new payment 3DS save card'
              ),
              MonriButton(() {
                Navigator.pushNamed(
                    context, AvailableAppRoutes.SAVED_CARD,
                    arguments: {'req_arg': ObjectArgument(true, false)}
                );
              },
                  'pay with saved card'
              ),
              MonriButton(() {
                Navigator.pushNamed(
                    context, AvailableAppRoutes.SAVED_CARD,
                    arguments: {'req_arg': ObjectArgument(true, true)}
                );
              },
                  'pay with 3DS saved card'
              ),
              MonriButton(() {
                Platform.isAndroid ? payWithGooglePay() : payWithApplePay();
              },
                  'Pay with $platformPayment'
              ),
            ],
          ),
        ),
      ),
    );
  }

  void payWithGooglePay() async {
    Map data = {};
    try {
      var platform = MethodChannel('monri.create.payment.session.channel');
      final monriPayments = MonriPayments.create();
      var clientSecret = await platform.invokeMethod('monri.create.payment.session.method');

      var arguments = jsonDecode(_getGooglePayJsonData(
          clientSecret: clientSecret,
          cardholderName: "Customer12"
      ));
      var result = await monriPayments.confirmGooglePayPayment(GooglePayConfirmPaymentParams.fromJSON(arguments));
      data = result.toJson();
      print(data);
    } on PlatformException catch (e) {
      data = {"status": "error", "message": e.message, "code": e.code};
      print(data);
    } catch (e) {
      data = {"status": "error", "message": e.toString()};
      print(data);
    }

  }

  Future<void> payWithApplePay() async {
    Map data = {};
    try {
      var platform = MethodChannel('monri.create.payment.session.channel');
      final monriPayments = MonriPayments.create();
      var clientSecret = await platform.invokeMethod('monri.create.payment.session.method');

      var arguments = jsonDecode(_getApplePayJsonData(
          clientSecret: clientSecret,
          cardholderName: "Customer12",
          applePayMerchantID: "merchant.monri.example"
      ));
      var result = await monriPayments.confirmApplePayPayment(ApplePayConfirmPaymentParams.fromJSON(arguments));
      data = result.toJson();
      print(data);
    } on PlatformException catch (e) {
      data = {"status": "error", "message": e.message, "code": e.code};
      print(data);
    } catch (e) {
      data = {"status": "error", "message": e.toString()};
      print(data);
    }

  }
}

String _getApplePayJsonData({
  required String clientSecret,
  required String cardholderName,
  required String applePayMerchantID
}){
  return """
{
  "is_development_mode": true,
  "authenticity_token": "REPLACE_WITH_YOUR_AUTHENTICITY_TOKEN",
  "applePayMerchantID": "$applePayMerchantID",
  "pkPaymentButtonStyle":null,
  "pkPaymentButtonType":null,
  "client_secret": "$clientSecret",
  "transaction_params": {
      "full_name": "$cardholderName",
      "address": "N/A",
      "city": "Sarajevo",
      "zip": "71000",
      "phone": "N/A",
      "country": "BA",
      "email": "monri.flutter@gmail.com",
      "custom_params": ""
  }
}
""";
}

String _getGooglePayJsonData({
  required String clientSecret,
  required String cardholderName,
}){
  return """
{
  "is_development_mode": true,
  "authenticity_token": "c6301017117302601b823874972a97acce96f2df",
  "client_secret": "$clientSecret",
  "googlePay": true,
  "transaction_params": {
      "full_name": "$cardholderName",
      "address": "N/A",
      "city": "Sarajevo",
      "zip": "71000",
      "phone": "N/A",
      "country": "BA",
      "email": "monri.flutter@gmail.com",
      "custom_params": ""
  }
}
""";
}
