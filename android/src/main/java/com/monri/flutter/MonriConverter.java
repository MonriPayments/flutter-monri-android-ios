package com.monri.flutter;

import java.util.Map;

public class MonriConverter {
    final Object arguments;

    MonriConverter(Object arguments) {
        this.arguments = arguments;
    }


    FlutterConfirmPaymentParams process() {
        Map<String, Object> request = (Map<String, Object>) arguments;

        FlutterConfirmPaymentParams flutterConfirmPaymentParams;

        if (request.containsKey("card")) {
            flutterConfirmPaymentParams = FlutterConfirmPaymentParams.forCard(request);
        } else if (request.containsKey("saved_card")) {
            flutterConfirmPaymentParams = FlutterConfirmPaymentParams.forSavedCard(request);
        } else {
            throw new IllegalStateException("Unsupported payment method, 'card' or 'saved_card' not found");
        }

        return flutterConfirmPaymentParams;
    }

}
