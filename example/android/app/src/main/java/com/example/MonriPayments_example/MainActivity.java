package com.example.MonriPayments_example;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.example.MonriPayments_example.monri_http_helper.Consumer;
import com.example.MonriPayments_example.monri_http_helper.MonriHttpHelper;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterFragmentActivity {
    private static final String CHANNEL = "monri.create.payment.session.channel";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("monri.create.payment.session.method")) {
                                createPaymentSession(result);
                            } else {
                                result.notImplemented();
                            }
                        });
    }

    private void createPaymentSession(MethodChannel.Result result) {
        try {
            MonriHttpHelper.createPaymentSession(new Consumer<String>() {
                @Override
                public void accept(String clientSecret) {
                    if (clientSecret != null) {
                        runOnUiThread(() -> result.success(clientSecret));
                    } else {
                        runOnUiThread(() -> result.error("PAYMENT_SESSION_ERROR", 
                                "Failed to create payment session", null));
                    }
                }
            }).execute();
        } catch (Exception e) {
            System.out.println("Error while creating payment");
            e.printStackTrace();
            result.error("PAYMENT_SESSION_ERROR", e.getMessage(), null);
        }
    }
}
