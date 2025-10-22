package com.monri.flutter;

import org.json.JSONObject;

import java.util.Map;

public class MonriConverter {
    final Object arguments;

    MonriConverter(Object arguments) {
        this.arguments = arguments;
    }


    @SuppressWarnings("unchecked")
    FlutterConfirmPaymentParams process() {
        Map<String, Object> request = (Map<String, Object>) arguments;

        FlutterConfirmPaymentParams flutterConfirmPaymentParams;

        if (request.containsKey("card")) {
            flutterConfirmPaymentParams = FlutterConfirmPaymentParams.forCard(request);
        } else if (request.containsKey("saved_card")) {
            flutterConfirmPaymentParams = FlutterConfirmPaymentParams.forSavedCard(request);
        } else if (request.containsKey("googlePay")) {
            flutterConfirmPaymentParams = FlutterConfirmPaymentParams.forGooglePay(request);
        } else {
            throw new IllegalStateException("Unsupported payment method, 'card', 'saved_card' or 'googlepay' not found");
        }

        return flutterConfirmPaymentParams;
    }

}
