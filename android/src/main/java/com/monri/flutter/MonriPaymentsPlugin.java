package com.monri.flutter;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

import androidx.annotation.NonNull;

import com.monri.android.Monri;
import com.monri.android.model.ConfirmPaymentParams;
import com.monri.android.model.MonriApiOptions;

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
    private MonriPaymentsDelegate delegate;
    private FlutterPluginBinding pluginBinding;
    private ActivityPluginBinding activityBinding;
    private Application application;
    private Activity activity;
    private Monri monri;

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
        MonriApiOptions monriApiOptions = flutterConfirmPaymentParams.monriApiOptions();
        ConfirmPaymentParams confirmPaymentParams = flutterConfirmPaymentParams.confirmPaymentParams();

        MonriPaymentsPlugin.writeMetaData(this.activity, String.format("Android-SDK:Flutter:%s", BuildConfig.MONRI_FLUTTER_PLUGIN_VERSION));

        this.monri = new Monri(this.activity, monriApiOptions);
        this.delegate.setMonri(this.monri);
        this.delegate.setConfirmPaymentResult(result);

        this.monri.confirmPayment(this.activity, confirmPaymentParams);
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

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activityBinding = binding;
        setup(
                pluginBinding.getBinaryMessenger(),
                (Application) pluginBinding.getApplicationContext(),
                activityBinding.getActivity(),
                null,
                activityBinding);
    }

    private void setup(
            final BinaryMessenger messenger, final Application application,
            final Activity activity,
            final PluginRegistry.Registrar registrar,
            final ActivityPluginBinding activityBinding) {

        this.activity = activity;
        this.application = application;
        this.delegate = new MonriPaymentsDelegate(this.monri);
        channel = new MethodChannel(messenger, CHANNEL);
        channel.setMethodCallHandler(this);
        if (registrar != null) {
            // V1 embedding setup for activity listeners.
            registrar.addActivityResultListener(delegate);
        } else {
            // V2 embedding setup for activity listeners.
            activityBinding.addActivityResultListener(delegate);
        }

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
        activityBinding.removeActivityResultListener(delegate);
        activityBinding = null;
        delegate = null;
        channel.setMethodCallHandler(null);
        channel = null;
        application = null;
    }

    private static void writeMetaData(Context context, String library) {
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
        sharedPreferences.edit().putString("com.monri.meta.library", library).apply();
    }
}
