import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:MonriPayments/MonriPayments.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map _data = {};
  final monriPayments = MonriPayments.create();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    Map data;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      var arguments = jsonDecode(_jsonData);
      data = (await monriPayments.confirmPayment(arguments)).toJson();
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
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text(_data.toString()),
        ),
      ),
    );
  }
}



String _a = "{\"email\":\"s.nazdrajic@gmail.com\",\"user_id\":\"460\",\"name\":\"| cardHolderName |\",\"phone_number\":\"0603207111\",\"platform\":\"flutter macos\"}"
;

String _jsonData = """
{
  "is_development_mode": true,
  "authenticity_token": "a6d41095984fc60fe81cd3d65ecafe56d4060ca9",
  "client_secret": "96fa0afa32884b81d323341160365356f4a994d1",
  "card": {
    "pan": "4111111111111111",
    "expiration_date": "2010",
    "cvv": "111",
    "tokenize_pan": "false"
  },
  "transaction": {
    "data": {
      "ch_full_name": "| cardHolderName |",
      "ch_address": "N/A",
      "ch_city": "Sarajevo",
      "ch_zip": "71000",
      "ch_phone": "N/A",
      "ch_country": "BA",
      "ch_email": "s.nazdrajic@gmail.com",
      "custom_params": ""
    }
  }
}
""";
