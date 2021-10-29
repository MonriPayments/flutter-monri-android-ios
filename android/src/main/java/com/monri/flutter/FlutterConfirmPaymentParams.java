package com.monri.flutter;

import com.monri.android.model.Card;
import com.monri.android.model.ConfirmPaymentParams;
import com.monri.android.model.CustomerParams;
import com.monri.android.model.MonriApiOptions;
import com.monri.android.model.PaymentMethodParams;
import com.monri.android.model.SavedCard;
import com.monri.android.model.TransactionParams;

import java.util.Map;

public class FlutterConfirmPaymentParams {

    private boolean developmentMode;
    private String authenticityToken;
    private String clientSecret;

    private FlutterCard card;
    private FlutterSavedCard savedCard;

    private FlutterTransactionParams transactionParams;

    private FlutterConfirmPaymentParams(boolean developmentMode, String authenticityToken, String clientSecret, FlutterCard card, FlutterSavedCard savedCard, FlutterTransactionParams transactionParams) {
        this.developmentMode = developmentMode;
        this.authenticityToken = authenticityToken;
        this.clientSecret = clientSecret;
        this.card = card;
        this.savedCard = savedCard;
        this.transactionParams = transactionParams;
    }

    private PaymentMethodParams paymentMethodParams() {
        if (card != null) {
            return new Card(card.pan, card.month, card.year, card.cvv).setTokenizePan(card.tokenizePan).toPaymentMethodParams();
        } else {
            return new SavedCard(savedCard.panToken, savedCard.cvv).toPaymentMethodParams();
        }
    }

    private TransactionParams transactionParams() {
        final CustomerParams customerParams = new CustomerParams()
                .setAddress(transactionParams.address)
                .setFullName(transactionParams.fullName)
                .setCity(transactionParams.city)
                .setZip(transactionParams.zip)
                .setPhone(transactionParams.phone)
                .setCountry(transactionParams.country)
                .setEmail(transactionParams.email);

        return TransactionParams.create()
                .set("custom_params", transactionParams.customParams)
                .set(customerParams);
    }

    ConfirmPaymentParams confirmPaymentParams() {
        return ConfirmPaymentParams.create(clientSecret, paymentMethodParams(), transactionParams());
    }

    MonriApiOptions monriApiOptions() {
        return MonriApiOptions.create(authenticityToken, developmentMode);
    }

    private static FlutterCard card(Map<String, Object> cardMap) {

        String number = (String) cardMap.get("pan");
        String cvv = (String) cardMap.get("cvv");
        boolean tokenizePan = (Boolean) cardMap.get("tokenize_pan");
        int expYear = (Integer) cardMap.get("expiry_year");
        int expMonth = (Integer) cardMap.get("expiry_month");
        return new FlutterCard(number, cvv, expYear, expMonth, tokenizePan);
    }


    private static FlutterSavedCard savedCard(Map<String, Object> cardMap) {
        return new FlutterSavedCard((String) cardMap.get("pan_token"), (String) cardMap.get("cvv"));
    }

    public static FlutterConfirmPaymentParams forCard(Map<String, Object> map) {
        return create(map, card((Map<String, Object>) map.get("card")), null);
    }

    private static FlutterConfirmPaymentParams create(Map<String, Object> request, FlutterCard card, FlutterSavedCard savedCard) {
        String authenticityToken = (String) request.get("authenticity_token");
        String clientSecret = (String) request.get("client_secret");
        boolean developmentMode = (boolean) request.get("is_development_mode");
        Map<String, Object> transactionParamsJSON = (Map<String, Object>) request.get("transaction_params");

        FlutterTransactionParams transactionParams = new FlutterTransactionParams(
                (String) transactionParamsJSON.get("order_info"),
                (String) transactionParamsJSON.get("email"),
                (String) transactionParamsJSON.get("full_name"),
                (String) transactionParamsJSON.get("address"),
                (String) transactionParamsJSON.get("city"),
                (String) transactionParamsJSON.get("zip"),
                (String) transactionParamsJSON.get("country"),
                (String) transactionParamsJSON.get("custom_params"),
                (String) transactionParamsJSON.get("phone")
        );

        return new FlutterConfirmPaymentParams(developmentMode, authenticityToken, clientSecret, card, savedCard, transactionParams);
    }

    public static FlutterConfirmPaymentParams forSavedCard(Map<String, Object> map) {
        return create(map, null, savedCard((Map<String, Object>) map.get("saved_card")));
    }

    static class FlutterTransactionParams {
        String orderInfo;
        String email;
        String fullName;
        String address;
        String city;
        String zip;
        String phone;
        String country;
        String customParams;

        FlutterTransactionParams(String orderInfo,
                                 String email, String fullName, String address, String city, String zip, String country, String customParams,
                                 String phone) {
            this.orderInfo = orderInfo;
            this.email = email;
            this.fullName = fullName;
            this.address = address;
            this.city = city;
            this.zip = zip;
            this.country = country;
            this.customParams = customParams;
            this.phone = phone;
        }
    }

    static class FlutterCard {
        String pan;
        String cvv;
        int year;
        int month;
        boolean tokenizePan;

        FlutterCard(String pan, String cvv, int year,
                    int month, boolean tokenizePan) {
            this.pan = pan;
            this.cvv = cvv;
            this.tokenizePan = tokenizePan;
            this.year = year;
            this.month = month;
        }
    }

    static class FlutterSavedCard {
        String panToken;
        String cvv;

        FlutterSavedCard(String panToken, String cvv) {
            this.panToken = panToken;
            this.cvv = cvv;
        }
    }
}
