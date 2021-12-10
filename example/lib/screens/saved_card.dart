import 'dart:convert';

import 'package:MonriPayments/MonriPayments.dart';
import 'package:MonriPayments_example/utils/card_util.dart';
import 'package:MonriPayments_example/widgets/monri_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/object_argument.dart';

class SavedCard extends StatefulWidget{
  final ObjectArgument objectArgument;

  SavedCard({Key? key, required this.objectArgument});

  @override
  State<SavedCard> createState() => _SavedCardState();
}

class _SavedCardState extends State<SavedCard> {
  final monriPayments = MonriPayments.create();
  static const platform = MethodChannel('monri.create.payment.session.channel');

  Map _data = {};
  final _formKey = GlobalKey<FormState>();
  int? _cvv;


  void _validateInputs() {
    final FormState form = _formKey.currentState!;
    if (!form.validate()) {
      //todo show message
      // _showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      // Encrypt and send send payment details to payment gateway
      // _showInSnackBar('Payment card is valid, continue to pay...');
      continuePayment();
    }
  }

  Future<void> continuePayment() async {
    Map data = {};
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      var clientSecret = await platform.invokeMethod('monri.create.payment.session.method');
      var arguments = jsonDecode(_getSavedCardJsonData(
          clientSecret: clientSecret,
          cvv: _cvv!,
          is3DS: widget.objectArgument.threeDS
      ));
      data = (await monriPayments.savedCardPayment(SavedCardConfirmPaymentParams.fromJSON(arguments))).toJson();
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
              title: Text('Pay with ${widget.objectArgument.threeDS? '3DS' : ''} saved card'),
            ),
          body: Center(
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Form(
                      key: _formKey,
                      child: new ListView(
                        children: <Widget>[
                          new SizedBox(
                            height: 20.0,
                          ),
                          new TextFormField(
                            decoration: new InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide:  BorderSide(color: Colors.transparent),
                              ),
                              filled: true,
                              icon: CardUtils.getCardIcon(widget.objectArgument.threeDS? cardType3DS : cardType),
                              hintText: 'masked pan',
                              labelText: 'masked pan',
                            ),
                            style: TextStyle(
                                color: Colors.black45
                            ),
                            keyboardType: TextInputType.text,
                            initialValue: widget.objectArgument.threeDS? maskedPan3DS : maskedPan,
                            enabled: false,
                          ),
                          new SizedBox(
                            height: 30.0,
                          ),
                          new TextFormField(
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
                            validator: CardUtils.validateCVV,
                            keyboardType: TextInputType.number,
                            onSaved: (value) {
                              _cvv = int.parse(value!);
                            },
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
        ));
  }

}

const panToken = "d5719409d1b8eb92adae0feccd2964b805f93ae3936fdd9d8fc01a800d094584";
const maskedPan = "403530******4083";
const cardType = CardType.Visa;

const panToken3DS = "c32b3465be7278d239f68bb6d7623acf0530bf34574cf3b782754d281c76bd02";
const maskedPan3DS = "434179******0044";
const cardType3DS = CardType.Visa;

String _getSavedCardJsonData({
  required String clientSecret,
  required int cvv,
  required bool is3DS
}){
  return """
{
  "is_development_mode": true,
  "authenticity_token": "a6d41095984fc60fe81cd3d65ecafe56d4060ca9",
  "client_secret": "$clientSecret",
  "card": {
    "pan_token": "${is3DS? panToken3DS : panToken}",
    "cvv": "$cvv"
  },
  "transaction_params": {
      "full_name": "Adnan Omerović",
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