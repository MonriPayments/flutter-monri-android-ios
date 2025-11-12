package com.monri.flutter;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;

import com.monri.flutter.BuildConfig;
import com.monri.android.Monri;
import com.monri.android.googlepay.GooglePayButtonOptions;
import com.monri.android.model.ConfirmPaymentParams;

import androidx.activity.result.ActivityResultCaller;
import androidx.annotation.NonNull;
import androidx.preference.PreferenceManager;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

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
    private static final String CONFIRM_GOOGLE_PAY = "confirmGooglePayment";
    private MethodChannel channel;
    private Boolean devMode = true;
    private FlutterPluginBinding pluginBinding;
    private ActivityPluginBinding activityBinding;
    private Application application;
    private Activity activity;
    private Monri monri;
    private final PaymentResultMapper paymentResultMapper = new PaymentResultMapper();

    private void initMonri() {
        if (activity != null && monri == null) {
            monri = new Monri((ActivityResultCaller) this.activity);
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (CONFIRM_PAYMENT.equals(call.method)) {
            monriConfirmPayment(call.arguments, result);
        } else if (CONFIRM_GOOGLE_PAY.equals(call.method)) {
            confirmGooglePayPayment(call.arguments, result);
        } else {
            result.notImplemented();
        }
    }

    private void monriConfirmPayment(final Object arguments, final MethodChannel.Result result) {

        final FlutterConfirmPaymentParams flutterConfirmPaymentParams = new MonriConverter(arguments).process();
        final ConfirmPaymentParams confirmPaymentParams = flutterConfirmPaymentParams.confirmPaymentParams();

        MonriPaymentsPlugin.writeMetaData(this.activity, String.format("Android-SDK:Flutter:%s", BuildConfig.MONRI_FLUTTER_PLUGIN_VERSION));

        monri.setMonriApiOptions(flutterConfirmPaymentParams.monriApiOptions());

        this.monri.confirmPayment(confirmPaymentParams, (paymentResult, throwable) -> {
            if (throwable != null) {
                result.error("payment_error", throwable.getMessage(), null);
                return;
            }

            if (paymentResult != null) {
                result.success(paymentResultMapper.mapPaymentResultToFlutterResult(paymentResult));
            }
        });
    }

    private void confirmGooglePayPayment(Object arguments, MethodChannel.Result result) {

        final FlutterConfirmPaymentParams flutterConfirmPaymentParams = new MonriConverter(arguments).process();
        final ConfirmPaymentParams confirmPaymentParams = flutterConfirmPaymentParams.confirmPaymentParams();

        MonriPaymentsPlugin.writeMetaData(this.activity, String.format("Android-SDK:Flutter:%s", BuildConfig.MONRI_FLUTTER_PLUGIN_VERSION));

        monri.setMonriApiOptions(flutterConfirmPaymentParams.monriApiOptions());

        final FlutterConfirmPaymentParams.FlutterGooglePay gPayParams = flutterConfirmPaymentParams.getGooglePayData();

        final GooglePayButtonOptions googlePayButtonOptions = new GooglePayButtonOptions(gPayParams.gPayButtonType, gPayParams.gPayTheme, gPayParams.gPayCornerRadius);

        this.monri.confirmPayment(confirmPaymentParams, (paymentResult, throwable) -> {
            if (throwable != null) {
                result.error("payment_error", throwable.getMessage(), null);
                return;
            }

            if(paymentResult != null) {
                result.success(paymentResultMapper.mapPaymentResultToFlutterResult(paymentResult));
            }

        }, googlePayButtonOptions);
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

        channel = new MethodChannel(messenger, CHANNEL);
        channel.setMethodCallHandler(this);

        initMonri();
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
            activityBinding = null;
        }
        monri = null;
        application = null;
    }

    private static void writeMetaData(Context context, String library) {
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
        sharedPreferences.edit().putString("com.monri.meta.library", library).apply();
    }
}
