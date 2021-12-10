import 'dart:convert';

import 'package:MonriPayments/MonriPayments.dart';
import 'package:MonriPayments_example/models/object_argument.dart';
import 'package:MonriPayments_example/widgets/monri_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/card_util.dart';
import '../utils/input_formatters.dart';
import '../utils/string_messages.dart';

class NewPayment extends StatefulWidget {
  final ObjectArgument objectArgument;

  NewPayment({Key? key, required this.objectArgument});

  @override
  State<NewPayment> createState() => _NewPaymentState(objectArgument.threeDS);
}

class _NewPaymentState extends State<NewPayment> {
  Map _data = {};
  final _cardNumberFocusNode = FocusNode();
  final _expirationDateFocusNode = FocusNode();
  final _cvvFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _autoValidateMode = AutovalidateMode.disabled;
  var numberController;


  _NewPaymentState(bool is3DS){
    numberController = new TextEditingController(text: is3DS ? threeDsPredefinedData["card_number"] : "");
  }

  var _cardType = CardType.Others;
  String? _cardHolderName;
  String? _cardNumber;
  int? _expirationMonth;
  int? _expirationYear;
  int? _cvv;

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
      continuePayment();
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> continuePayment() async {
    Map data = {};
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      var clientSecret = await platform.invokeMethod('monri.create.payment.session.method');
      var arguments = jsonDecode(_getJsonData(
          clientSecret: clientSecret,
          cardNumber: _cardNumber!,
          cvv: _cvv!,
          expirationMonth: _expirationMonth!,
          expirationYear: CardUtils.convertYearTo4Digits(_expirationYear!),
          cardHolderName: _cardHolderName!,
          tokenize_pan: widget.objectArgument.savedCard
      ));
      data = (await monriPayments.confirmPayment(CardConfirmPaymentParams.fromJSON(arguments))).toJson();
      // print(data);
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
          title: Text('New Payment ${widget.objectArgument.savedCard ? 'save card':''}'),
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
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide:  BorderSide(color: Colors.transparent),
                            ),
                            filled: true,
                            icon: const Icon(
                              Icons.person,
                              size: 40.0,
                              color: Colors.grey,
                            ),
                            labelText: 'Card Holder Name',
                          ),
                          style: TextStyle(
                            color: widget.objectArgument.threeDS ? Colors.black45 : Colors.blue
                          ),
                          initialValue: widget.objectArgument.threeDS? threeDsPredefinedData["card_holder_name"] : "",
                          enabled: widget.objectArgument.threeDS? false : true,
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
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide:  BorderSide(color: Colors.transparent),
                            ),
                            filled: true,
                            icon: CardUtils.getCardIcon(_cardType),
                            labelText: 'Card Number',
                          ),
                          style: TextStyle(
                              color: widget.objectArgument.threeDS ? Colors.black45 : Colors.blue
                          ),
                          enabled: widget.objectArgument.threeDS? false : true,
                          onSaved: (String? value) {
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
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide:  BorderSide(color: Colors.transparent),
                            ),
                            filled: true,
                            icon: new Image.asset(
                              'assets/images/card_cvv.png',
                              width: 40.0,
                              color: Colors.grey,
                            ),
                            hintText: 'Number behind the card',
                            labelText: 'CVV',
                          ),
                          style: TextStyle(
                              color: widget.objectArgument.threeDS ? Colors.black45 : Colors.blue
                          ),
                          initialValue: widget.objectArgument.threeDS? threeDsPredefinedData["cvv"] : "",
                          enabled: widget.objectArgument.threeDS? false : true,
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
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide:  BorderSide(color: Colors.transparent),
                            ),
                            filled: true,
                            icon: new Image.asset(
                              'assets/images/calender.png',
                              width: 40.0,
                              color: Colors.grey,
                            ),
                            hintText: 'MM/YY',
                            labelText: 'Expiry Date',
                          ),
                          style: TextStyle(
                              color: widget.objectArgument.threeDS ? Colors.black45 : Colors.blue
                          ),
                          initialValue: widget.objectArgument.threeDS? '${threeDsPredefinedData["expiration_month"]}/${threeDsPredefinedData["expiration_year"]%100}' :"",
                          enabled: widget.objectArgument.threeDS? false : true,
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
                             MonriButton(
                                 (){_validateInputs();},
                               'Start payment'
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

const Map<String, dynamic> threeDsPredefinedData = {
  "card_number": "4341792000000044",
  "cvv": "123",
  "expiration_month": 12,
  "expiration_year": 2029,
  "card_holder_name": "Adnan Omerović"
};

String _getJsonData({
  required String clientSecret,
  required String cardNumber,
  required int cvv,
  required int expirationMonth,
  required int expirationYear,
  required String cardHolderName,
  required bool tokenize_pan
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
    "tokenize_pan": $tokenize_pan
  },
  "transaction_params": {
      "full_name": "$cardHolderName",
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