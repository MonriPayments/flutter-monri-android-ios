package com.example.MonriPayments_example.monri_http_helper;

public enum MonriHttpMethod {
    GET("GET"),
    POST("POST");

    private final String value;


    MonriHttpMethod(final String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }
}
