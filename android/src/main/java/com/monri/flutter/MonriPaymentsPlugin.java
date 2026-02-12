package com.monri.flutter;

import static com.monri.flutter.ScanDocHelpers.extractionConfigurationFromJson;
import static com.monri.flutter.ScanDocHelpers.extractionResponseToJson;
import static com.monri.flutter.ScanDocHelpers.scanDocApiOptionsFromJson;
import static com.monri.flutter.ScanDocHelpers.validationConfigurationFromJson;
import static com.monri.flutter.ScanDocHelpers.validationResponseToJson;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import com.monri.android.ExtractionConfiguration;
import com.monri.android.ResultCallback;
import com.monri.android.ValidationConfiguration;
import com.monri.android.model.ExtractionResponse;
import com.monri.android.model.ScanDocApiOptions;
import com.monri.android.model.ValidationResponse;
import com.monri.android.Monri;
import com.monri.android.googlepay.GooglePayButtonOptions;
import com.monri.android.model.ConfirmPaymentParams;
import com.monri.android.ScanDocApi;

import androidx.activity.result.ActivityResultCaller;
import androidx.annotation.NonNull;
import androidx.preference.PreferenceManager;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

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
    private static final String INIT_SCAN_DOC = "initScanDoc";
    private static final String EXTRACT_SCANNED_CARD = "extractScannedCard";
    private static final String VALIDATE_SCANNED_CARD = "validateScannedCard";
    private MethodChannel channel;
    private Boolean devMode = true;
    private FlutterPluginBinding pluginBinding;
    private ActivityPluginBinding activityBinding;
    private Application application;
    private Activity activity;
    private Monri monri;
    private final PaymentResultMapper paymentResultMapper = new PaymentResultMapper();
    private ScanDocApi scanDocApi;

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
        } else if (INIT_SCAN_DOC.equals(call.method)) {
            initScanDoc(call.arguments, result);
        } else if (EXTRACT_SCANNED_CARD.equals(call.method)) {
            extractScannedCard(call.arguments, result);
        } else if (VALIDATE_SCANNED_CARD.equals(call.method)) {
            validateScannedCard(call.arguments, result);
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

    private Bitmap base64ToBitmap(String base64) {
        byte[] decoded = android.util.Base64.decode(base64, android.util.Base64.DEFAULT);
        return BitmapFactory.decodeByteArray(decoded, 0, decoded.length);
    }

    private void initScanDoc(Object arguments, Result result) {
        if (!(arguments instanceof Map)) {
            result.error("INVALID_ARGS", "Arguments must be a map", null);
            return;
        }

        Map<String, Object> args = (Map<String, Object>) arguments;

        ScanDocApiOptions options = scanDocApiOptionsFromJson(args);

        scanDocApi = new ScanDocApi(options);
        result.success(null);
    }

    private void extractScannedCard(Object arguments, Result result) {

        if (!(arguments instanceof Map)) {
            result.error("INVALID_ARGS", "Arguments must be a map", null);
            return;
        }

        Map<String, Object> args = (Map<String, Object>) arguments;

        String base64 = (String) args.get("base64Img");
        if (base64 == null) {
            result.error("INVALID_IMAGE", "Missing base64Img", null);
            return;
        }

        Bitmap bitmap = base64ToBitmap(base64);

        ExtractionConfiguration config = null;
        if (args.containsKey("configuration") && args.get("configuration") instanceof Map) {
            config = extractionConfigurationFromJson(
                    (Map<String, Object>) args.get("configuration")
            );
        }

        if (config != null) {
            scanDocApi.extractDataFromScannedCard(bitmap, config, new ResultCallback<ExtractionResponse>() {
                @Override
                public void onSuccess(ExtractionResponse response) {
                    result.success(extractionResponseToJson(response));
                }

                @Override
                public void onError(Throwable error) {
                    result.error("EXTRACTION_ERROR", error.getMessage(), null);
                }
            });
        } else {
            scanDocApi.extractDataFromScannedCard(bitmap, new ResultCallback<ExtractionResponse>() {
                @Override
                public void onSuccess(ExtractionResponse response) {
                    result.success(extractionResponseToJson(response));
                }

                @Override
                public void onError(Throwable error) {
                    result.error("EXTRACTION_ERROR", error.getMessage(), null);
                }
            });
        }
    }

    private void validateScannedCard(Object arguments, Result result) {

        if (!(arguments instanceof Map)) {
            result.error("INVALID_ARGS", "Arguments must be a map", null);
            return;
        }

        Map<String, Object> args = (Map<String, Object>) arguments;

        List<String> base64Images = (List<String>) args.get("base64Imgs");
        if (base64Images == null || base64Images.isEmpty()) {
            result.error("INVALID_IMAGES", "Missing base64Imgs", null);
            return;
        }

        List<Bitmap> bitmapList = new ArrayList<>();
        for (String img : base64Images) {
            bitmapList.add(base64ToBitmap(img));
        }

        Bitmap[] bitmaps = bitmapList.toArray(new Bitmap[0]);

        ValidationConfiguration config = new ValidationConfiguration();
        if (args.containsKey("configuration") && args.get("configuration") instanceof Map) {
            config = validationConfigurationFromJson(
                    (Map<String, Object>) args.get("configuration")
            );
        }

        scanDocApi.validateScannedCard(bitmaps, config, new ResultCallback<ValidationResponse>() {
            @Override
            public void onSuccess(ValidationResponse response) {
                result.success(validationResponseToJson(response));
            }

            @Override
            public void onError(Throwable error) {
                result.error("EXTRACTION_ERROR", error.getMessage(), null);
            }
        });

    }


}
