package com.monri.flutter;

import com.monri.android.model.Card;
import com.monri.android.model.ConfirmPaymentParams;
import com.monri.android.model.CustomerParams;
import com.monri.android.model.GooglePayPayment;
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

    private FlutterGooglePay googlePayData;

    private FlutterConfirmPaymentParams(boolean developmentMode, String authenticityToken, String clientSecret,
                                        FlutterCard card, FlutterSavedCard savedCard, FlutterTransactionParams transactionParams, FlutterGooglePay googlePayData) {
        this.developmentMode = developmentMode;
        this.authenticityToken = authenticityToken;
        this.clientSecret = clientSecret;
        this.card = card;
        this.savedCard = savedCard;
        this.transactionParams = transactionParams;
        this.googlePayData = googlePayData;
    }

    private PaymentMethodParams paymentMethodParams() {
        if (card != null) {
            return new Card(card.pan, card.month, card.year, card.cvv).setTokenizePan(card.tokenizePan)
                                                                      .toPaymentMethodParams();
        } else if (savedCard != null) {
            return new SavedCard(savedCard.panToken, savedCard.cvv).toPaymentMethodParams();
        } else if (googlePayData != null) {
            return new GooglePayPayment(GooglePayPayment.Provider.GOOGLE_PAY).toPaymentMethodParams();
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

        final TransactionParams rv = TransactionParams.create()
                                                      .set("custom_params", transactionParams.customParams)
                                                      .set(customerParams);

        if (Boolean.TRUE.equals(transactionParams.moto)) {
            rv.set("moto", "true");
        }

        return rv;
    }

    ConfirmPaymentParams confirmPaymentParams() {
        return ConfirmPaymentParams.create(clientSecret, paymentMethodParams(), transactionParams());
    }

    MonriApiOptions monriApiOptions() {
        return MonriApiOptions.create(authenticityToken, developmentMode);
    }

    MonriApiOptions monriApiOptions(String authenticityToken, boolean developmentMode) {
        return MonriApiOptions.create(authenticityToken, developmentMode);
    }

    public FlutterGooglePay getGooglePayData() {
        return googlePayData;
    }

    @SuppressWarnings("unchecked")
    private static FlutterCard card(Map<String, Object> cardMap) {

        String number = (String) cardMap.get("pan");
        String cvv = (String) cardMap.get("cvv");
        boolean tokenizePan = (Boolean) cardMap.get("tokenize_pan");
        int expYear = (Integer) cardMap.get("expiry_year");
        int expMonth = (Integer) cardMap.get("expiry_month");
        return new FlutterCard(number, cvv, expYear, expMonth, tokenizePan);
    }

    @SuppressWarnings("unchecked")
    private static FlutterSavedCard savedCard(Map<String, Object> cardMap) {
        return new FlutterSavedCard(
                (String) cardMap.get("pan_token"),
                (String) cardMap.get("cvv")
        );
    }

    @SuppressWarnings("unchecked")
    public static FlutterConfirmPaymentParams forCard(Map<String, Object> map) {
        return create(map, card((Map<String, Object>) map.get("card")), null, null);
    }

    @SuppressWarnings("unchecked")
    public static FlutterConfirmPaymentParams forSavedCard(Map<String, Object> map) {
        return create(map, null, savedCard((Map<String, Object>) map.get("saved_card")), null);
    }

    public static FlutterConfirmPaymentParams forGooglePay(Map<String, Object> map) {
        final int gPayType;
        final int gPayTheme;
        final int gPayCornerRadius;

        Object typeObj = map.get("gPayButtonType");
        if (typeObj != null) {
            gPayType = (int) typeObj;
        } else {
            gPayType = 1; // or some default value
        }

        Object themeObj = map.get("gPayButtonTheme");
        if (typeObj != null) {
            gPayTheme = (int) themeObj;
        } else {
            gPayTheme = 1; // or some default value
        }

        Object cornerRadiusObj = map.get("gPayCornerRadius");
        if (typeObj != null) {
            gPayCornerRadius = (int) cornerRadiusObj;
        } else {
            gPayCornerRadius = 100; // or some default value
        }

        return create(map, null, null, new FlutterGooglePay(gPayTheme, gPayType, gPayCornerRadius));
    }

    @SuppressWarnings("unchecked")
    private static FlutterConfirmPaymentParams create(Map<String, Object> request, FlutterCard card,
                                                      FlutterSavedCard savedCard, FlutterGooglePay googlePayData) {

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
                (String) transactionParamsJSON.get("phone"),
                (Boolean) transactionParamsJSON.get("moto"));

        return new FlutterConfirmPaymentParams(developmentMode, authenticityToken, clientSecret, card, savedCard,
                                               transactionParams, googlePayData);
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
        Boolean moto;

        FlutterTransactionParams(String orderInfo,
                                 String email,
                                 String fullName,
                                 String address,
                                 String city,
                                 String zip,
                                 String country,
                                 String customParams,
                                 String phone,
                                 Boolean moto) {
            this.orderInfo = orderInfo;
            this.email = email;
            this.fullName = fullName;
            this.address = address;
            this.city = city;
            this.zip = zip;
            this.country = country;
            this.customParams = customParams;
            this.phone = phone;
            this.moto = moto;
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

    static class FlutterGooglePay {

        final int gPayTheme;
        final int gPayButtonType;
        final int gPayCornerRadius;

        FlutterGooglePay(final int gPayTheme, final int gPayButtonType, final int gPayCornerRadius) {
            this.gPayTheme = gPayTheme;
            this.gPayButtonType = gPayButtonType;
            this.gPayCornerRadius = gPayCornerRadius;
        }
    }
}
