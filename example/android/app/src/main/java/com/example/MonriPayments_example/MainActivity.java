package com.example.MonriPayments_example;

import androidx.annotation.NonNull;
import com.example.MonriPayments_example.monri_http_helper.MonriHttpHelper;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "monri.create.payment.session.channel";
    private static final String createPaymentSessionMethod = "monri.create.payment.session.method";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            // Note: this method is invoked on the main thread.
                            if (call.method.equals(createPaymentSessionMethod)) {
                                MonriHttpHelper.createPaymentSession(result::success).execute();
                            }
                        }
                );
    }
}
