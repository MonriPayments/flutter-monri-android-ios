import 'dart:convert';
import 'package:MonriPayments_example/card_util.dart';
import 'package:MonriPayments_example/string_messages.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:MonriPayments/MonriPayments.dart';

import 'input_formatters.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map _data = {};
  final _cardNumberFocusNode = FocusNode();
  final _expirationDateFocusNode = FocusNode();
  final _cvvFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _autoValidateMode = AutovalidateMode.disabled;
  var numberController = new TextEditingController();

  var _cardType = CardType.Others;
  String? _cardHolderName;
  String? _cardNumber;
  int? _expirationMonth;
  int? _expirationYear;
  int? _cvv;

  // String _result = "";

  final monriPayments = MonriPayments.create();
  static const platform = MethodChannel('monri.create.payment.session.channel');

  @override
  void initState() {
    super.initState();
    _cardType = CardType.Others;
    numberController.addListener(_getCardTypeFrmNumber);
    // initPlatformState();
  }

  @override
  void dispose() {
    _cardNumberFocusNode.dispose();
    _expirationDateFocusNode.dispose();
    _cvvFocusNode.dispose();
    super.dispose();
  }


  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController.text);
    CardType cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      this._cardType = cardType;
    });
  }

  void _validateInputs() {
    final FormState form = _formKey.currentState!;
    if (!form.validate()) {
      setState(() {
        _autoValidateMode =
            AutovalidateMode.always; // Start validating on every change.
      });
      // _showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      // Encrypt and send send payment details to payment gateway
      // _showInSnackBar('Payment card is valid, continue to pay...');
      initPlatformState();
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    Map data;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      var clientSecreet = await platform.invokeMethod('monri.create.payment.session.method');
      var arguments = jsonDecode(_getJsonData(
          clientSecret: clientSecreet,
          cardNumber: _cardNumber!,
          cvv: _cvv!,
          expirationMonth: _expirationMonth!,
          expirationYear: CardUtils.convertYearTo4Digits(_expirationYear!),
          cardHolderName: _cardHolderName!
      ));
      data = (await monriPayments.confirmPayment(CardConfirmPaymentParams.fromJSON(arguments))).toJson();
      print(data);
    } on PlatformException {
      data = {};
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _data = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Monri Plugin example app'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Form(
                key: _formKey,
                autovalidateMode: _autoValidateMode,
                child: new ListView(
                  children: <Widget>[
                    new SizedBox(
                      height: 20.0,
                    ),
                    new TextFormField(
                      decoration: const InputDecoration(
                        border: const UnderlineInputBorder(),
                        filled: true,
                        icon: const Icon(
                          Icons.person,
                          size: 40.0,
                        ),
                        labelText: 'Card Holder Name',
                      ),
                      onSaved: (String? value) {
                        _cardHolderName = value;
                      },
                      keyboardType: TextInputType.text,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_cardNumberFocusNode);
                      },
                      validator: (String? value) =>
                      value!.isEmpty ? ValidationMessages.filedRequired : null,
                    ),
                    new SizedBox(
                      height: 30.0,
                    ),
                    new TextFormField(
                      keyboardType: TextInputType.number,
                      focusNode: _cardNumberFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_cvvFocusNode);
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        new LengthLimitingTextInputFormatter(19),
                        new CardNumberInputFormatter()
                      ],
                      controller: numberController,
                      decoration: new InputDecoration(
                        border: const UnderlineInputBorder(),
                        filled: true,
                        icon: CardUtils.getCardIcon(_cardType),
                        labelText: 'Card Number',
                      ),
                      onSaved: (String? value) {
                        print('onSaved = $value');
                        print('Num controller has = ${numberController.text}');
                        _cardNumber = CardUtils.getCleanedNumber(value!);
                      },
                      validator: CardUtils.validateCardNum,
                    ),
                    new SizedBox(
                      height: 30.0,
                    ),
                    new TextFormField(
                      focusNode: _cvvFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_expirationDateFocusNode);
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        new LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: new InputDecoration(
                        border: const UnderlineInputBorder(),
                        filled: true,
                        icon: new Image.asset(
                          'assets/images/card_cvv.png',
                          width: 40.0,
                          color: Colors.grey[600],
                        ),
                        hintText: 'Number behind the card',
                        labelText: 'CVV',
                      ),
                      validator: CardUtils.validateCVV,
                      keyboardType: TextInputType.number,
                      onSaved: (value) {
                        _cvv = int.parse(value!);
                      },
                    ),
                    new SizedBox(
                      height: 30.0,
                    ),
                    new TextFormField(
                      focusNode: _expirationDateFocusNode,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        new LengthLimitingTextInputFormatter(4),
                        new CardMonthInputFormatter()
                      ],
                      decoration: new InputDecoration(
                        border: const UnderlineInputBorder(),
                        filled: true,
                        icon: new Image.asset(
                          'assets/images/calender.png',
                          width: 40.0,
                          color: Colors.grey[600],
                        ),
                        hintText: 'MM/YY',
                        labelText: 'Expiry Date',
                      ),
                      validator: CardUtils.validateDate,
                      keyboardType: TextInputType.number,
                      onSaved: (value) {
                        List<int> expiryDate = CardUtils.getExpiryDate(value!);
                        _expirationMonth = expiryDate[0];
                        _expirationYear = expiryDate[1];
                      },
                    ),
                    new SizedBox(
                      height: 50.0,
                    ),
                    new Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // _proceed();
                              _validateInputs();
                            },
                            child: Text('Start payment'),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          Text(_data.toString()),
                        ],
                      ),
                    )
                  ],
                ))
          )
        ),
      ),
    );
  }

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(value),
      duration: new Duration(seconds: 3),
    ));
  }
}

 String _getJsonData({
   required String clientSecret,
   required String cardNumber,
   required int cvv,
   required int expirationMonth,
   required int expirationYear,
   required String cardHolderName
 }){
    return """
{
  "is_development_mode": true,
  "authenticity_token": "a6d41095984fc60fe81cd3d65ecafe56d4060ca9",
  "client_secret": "$clientSecret",
  "card": {
    "pan": "$cardNumber",
    "cvv": "$cvv",
    "expiryMonth": "$expirationMonth",
    "expiryYear": "$expirationYear",
    "tokenize_pan": "false"
  },
  "transaction_params": {
      "full_name": "$cardHolderName",
      "address": "N/A",
      "city": "Sarajevo",
      "zip": "71000",
      "phone": "N/A",
      "country": "BA",
      "email": "s.nazdrajic@gmail.com",
      "custom_params": ""
  }
}
""";
 }
