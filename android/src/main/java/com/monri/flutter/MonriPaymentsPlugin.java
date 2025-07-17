package com.monri.flutter;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultCaller;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.ActivityResultRegistry;
import androidx.activity.result.contract.ActivityResultContract;
import androidx.annotation.NonNull;

import com.monri.android.ActionResultConsumer;
import com.monri.android.Monri;
import com.monri.android.activity.ConfirmPaymentActivity;
import com.monri.android.model.ConfirmPaymentParams;
import com.monri.android.model.MonriApiOptions;
import com.monri.android.model.PaymentResult;

import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

/**
 * MonriPaymentsPlugin
 */
public class MonriPaymentsPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private static final String CHANNEL = "MonriPayments";
    private static final String CONFIRM_PAYMENT = "confirmPayment";
    private MethodChannel channel;
    private String token = "c6301017117302601b823874972a97acce96f2df";
    private Boolean devMode = true;
    private MonriPaymentsDelegate delegate;
    private FlutterPluginBinding pluginBinding;
    private ActivityPluginBinding activityBinding;
    private Application application;
    private Activity activity;
    private Monri monri;

    private void tryInitMonri() {
        if (activity != null && token != null && devMode != null && monri == null){
            MonriApiOptions monriApiOptions = new MonriApiOptions(token, devMode);
            monri = new Monri((ActivityResultCaller)this.activity, monriApiOptions);
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

        if (CONFIRM_PAYMENT.equals(call.method)) {
            monriConfirmPayment(call.arguments, result);
        } else {
            result.notImplemented();
        }
    }

    private void monriConfirmPayment(Object arguments, MethodChannel.Result result) {
        
        FlutterConfirmPaymentParams flutterConfirmPaymentParams = new MonriConverter(arguments).process();
        ConfirmPaymentParams confirmPaymentParams = flutterConfirmPaymentParams.confirmPaymentParams();

        MonriPaymentsPlugin.writeMetaData(this.activity, String.format("Android-SDK:Flutter:%s", BuildConfig.MONRI_FLUTTER_PLUGIN_VERSION));

        System.out.println("MonriPaymentsPlugin: monriConfirmPayment called with params: " + confirmPaymentParams.toString());
        this.delegate.setConfirmPaymentResult(result);
        System.out.println("MonriPaymentsPlugin: calling confirmPayment with params: " + confirmPaymentParams.toString());

        this.monri.confirmPayment(confirmPaymentParams, new ActionResultConsumer<PaymentResult>() {
            @Override
            public void accept(PaymentResult paymentResult, Throwable throwable) {
                if (throwable != null) {
                    result.error("payment_error", throwable.getMessage(), null);
                    return;
                }

                if (paymentResult != null) {
                    java.util.Map<String, Object> response = new java.util.HashMap<>();
                    java.util.Map<String, Object> data = new java.util.HashMap<>();
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
                    result.success(response);
                }
            }
        });
        System.out.println("MonriPaymentsPlugin: confirmPayment called");
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        pluginBinding = binding;
    }

    //activity aware
    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        if (channel != null) {
            channel.setMethodCallHandler(null);
        }
    }

    private void setup(
            final BinaryMessenger messenger, final Application application,
            final Activity activity,
            final ActivityPluginBinding activityBinding) {

        this.activity = activity;
        this.application = application;
        this.delegate = new MonriPaymentsDelegate(null); // Initialize with null

        channel = new MethodChannel(messenger, CHANNEL);
        channel.setMethodCallHandler(this);

        tryInitMonri();
        
        // V2 embedding setup for activity listeners.
        if (activityBinding != null) {
            activityBinding.addActivityResultListener(delegate);
        }
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activityBinding = binding;
        setup(
                pluginBinding.getBinaryMessenger(),
                (Application) pluginBinding.getApplicationContext(),
                activityBinding.getActivity(),
                activityBinding);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        tearDown();
    }

    private void tearDown() {
        if (activityBinding != null) {
            activityBinding.removeActivityResultListener(delegate);
            activityBinding = null;
        }
        delegate = null;
        monri = null; // Also clear the monri instance
        application = null;
    }

    private static void writeMetaData(Context context, String library) {
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
        sharedPreferences.edit().putString("com.monri.meta.library", library).apply();
    }
}
