package com.monri.flutter;

import com.monri.android.model.PaymentResult;

import java.util.Map;

public class PaymentResultMapper {

    Map<String, Object> mapPaymentResultToFlutterResult(final PaymentResult paymentResult) {
        final Map<String, Object> response = new java.util.HashMap<>();
        final Map<String, Object> data = new java.util.HashMap<>();
        final String status = paymentResult.getStatus();

        data.put("status", paymentResult.getStatus());
        data.put("amount", paymentResult.getAmount());
        data.put("orderNumber", paymentResult.getOrderNumber());
        data.put("transactionType", paymentResult.getTransactionType());
        data.put("pan_token", paymentResult.getPanToken());
        java.util.List<String> errors = paymentResult.getErrors();
        if (errors != null) {
            data.put("errors", errors);
        }
        data.put("createdAt", paymentResult.getCreatedAt());
        data.put("currency", paymentResult.getCurrency());

        response.put("status", status);
        response.put("data", data);
        return response;
    }
}
