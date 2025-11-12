# MonriPayments

Flutter library for Monri Android/iOS SDK

## Installation

In pubspec.yaml add
```yaml
dependencies:
  MonriPayments:
    git:
      url: https://github.com/MonriPayments/flutter-monri-android-ios.git
```

#### Android Gradle

On your `build.gradle` file add this statement to the `dependencies` section:

```groovy
buildscript {
    //...
    dependencies {
        classpath 'com.android.tools.build:gradle:7.0.2'
    }
}
```

## Usage

```dart
import 'package:MonriPayments/MonriPayments.dart';
```

```dart
// ...
final monriPayments = MonriPayments.create();

Future<void> _continuePayment() async {
  Map data = {};
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    var clientSecret = "client_secret"; // create one on your backend
    var arguments = jsonDecode(_getJsonData(
        isDevelopment: true,
        clientSecret: clientSecret,
        cardNumber: "4341792000000044",
        cvv: 123,
        expirationMonth: 12,
        expirationYear: 2030,
        cardHolderName: "Adnan Omerovic",
        tokenizePan: true
    ));
    data = (await monriPayments.confirmPayment(CardConfirmPaymentParams.fromJSON(arguments))).toJson();
  } on PlatformException {
    data = {};
  }

}

String _getJsonData({
  required String clientSecret,
  required bool isDevelopment,
  required String cardNumber,
  required int cvv,
  required int expirationMonth,
  required int expirationYear,
  required String cardHolderName,
  required bool tokenizePan
}){
  return """
    {
        "is_development_mode": $isDevelopment,
        "authenticity_token": "a6d41095984fc60fe81cd3d65ecafe56d4060ca9", //available on merchant's dashboard
        "client_secret": "$clientSecret",
        "card": {
        "pan": "$cardNumber",
            "cvv": "$cvv",
            "expiryMonth": "$expirationMonth",
            "expiryYear": "$expirationYear",
            "tokenize_pan": $tokenizePan
    },
        "transaction_params": {
        "full_name": "$cardHolderName",
            "address": "N/A",
            "city": "Sarajevo",
            "zip": "71000",
            "phone": "N/A",
            "country": "BA",
            "email": "flutter@monri.com",
            "custom_params": ""
    }
    }
    """;
}
```

## Apple Pay

To use Apple Pay, required parameter is merchantID as well as setuping up profile to accept Apple Pay capability. 

For more information on how to setup the XCode project, follow native guidelines: [Monri iOS Apple Pay Wiki](https://github.com/MonriPayments/monri-ios/wiki/Apple-Pay-configuration)
To implement it in flutter, please refer to example project provided with the plugin.


## Google Pay

For more information on how to setup the Android project, follow native guidelines: [Monri Android Google Pay Wiki](https://github.com/MonriPayments/monri-android/wiki/Google-Pay-Integration)
To implement it in flutter, please refer to example project provided with the plugin.

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
