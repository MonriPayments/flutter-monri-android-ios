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

    //Const methods
    private static final String CONFIRM_PAYMENT = "confirmPayment";
    private static final String CONFIRM_GOOGLE_PAY = "confirmGooglePayment";
    private static final String INIT_SCAN_DOC = "initScanDoc";
    private static final String EXTRACT_SCANNED_CARD = "extractScannedCard";
    private static final String VALIDATE_SCANNED_CARD = "validateScannedCard";

    // Argument keys
    private static final String KEY_BASE64_IMG = "base64Img";
    private static final String KEY_BASE64_IMGS = "base64Imgs";
    private static final String KEY_CONFIGURATION = "configuration";

    // Error codes
    private static final String ERROR_INVALID_ARGS = "INVALID_ARGS";
    private static final String ERROR_INVALID_IMAGE = "INVALID_IMAGE";
    private static final String ERROR_INVALID_IMAGES = "INVALID_IMAGES";
    private static final String ERROR_EXTRACTION = "EXTRACTION_ERROR";
    private static final String ERROR_VALIDATION = "VALIDATION_ERROR";
    private static final String ERROR_MONRI_UNAVAILABLE = "MONRI_UNAVAILABLE";

    // Error messages
    private static final String MSG_ARGS_MUST_BE_MAP = "Arguments must be a map";
    private static final String MSG_MISSING_BASE64_IMG = "Missing base64Img";
    private static final String MSG_MISSING_BASE64_IMGS = "Missing base64Imgs";
    private static final String MSG_FAILED_DECODE_BITMAP = "Failed to decode base64 to bitmap";
    private static final String MSG_MONRI_UNAVAILABLE = "Monri SDK is not initialized yet. Please retry payment.";

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

    private Monri ensureMonriOrReport(MethodChannel.Result result) {
        if (monri != null) {
            return monri;
        }

        initMonri();
        if (monri != null) {
            return monri;
        }

        result.error(ERROR_MONRI_UNAVAILABLE, MSG_MONRI_UNAVAILABLE, null);
        return null;
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
        final Monri monriInstance = ensureMonriOrReport(result);
        if (monriInstance == null) {
            return;
        }

        final FlutterConfirmPaymentParams flutterConfirmPaymentParams = new MonriConverter(arguments).process();
        final ConfirmPaymentParams confirmPaymentParams = flutterConfirmPaymentParams.confirmPaymentParams();

        MonriPaymentsPlugin.writeMetaData(this.activity, String.format("Android-SDK:Flutter:%s", BuildConfig.MONRI_FLUTTER_PLUGIN_VERSION));

        monriInstance.setMonriApiOptions(flutterConfirmPaymentParams.monriApiOptions());

        monriInstance.confirmPayment(confirmPaymentParams, (paymentResult, throwable) -> {
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
        final Monri monriInstance = ensureMonriOrReport(result);
        if (monriInstance == null) {
            return;
        }

        final FlutterConfirmPaymentParams flutterConfirmPaymentParams = new MonriConverter(arguments).process();
        final ConfirmPaymentParams confirmPaymentParams = flutterConfirmPaymentParams.confirmPaymentParams();

        MonriPaymentsPlugin.writeMetaData(this.activity, String.format("Android-SDK:Flutter:%s", BuildConfig.MONRI_FLUTTER_PLUGIN_VERSION));

        monriInstance.setMonriApiOptions(flutterConfirmPaymentParams.monriApiOptions());

        final FlutterConfirmPaymentParams.FlutterGooglePay gPayParams = flutterConfirmPaymentParams.getGooglePayData();

        final GooglePayButtonOptions googlePayButtonOptions = new GooglePayButtonOptions(gPayParams.gPayButtonType, gPayParams.gPayTheme, gPayParams.gPayCornerRadius);

        monriInstance.confirmPayment(confirmPaymentParams, (paymentResult, throwable) -> {
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
        if (context == null) {
            return;
        }
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
        sharedPreferences.edit().putString("com.monri.meta.library", library).apply();
    }

    private Bitmap base64ToBitmap(final String base64) {
        final byte[] decoded = android.util.Base64.decode(base64, android.util.Base64.DEFAULT);
        return BitmapFactory.decodeByteArray(decoded, 0, decoded.length);
    }

    private void initScanDoc(final Object arguments, final Result result) {
        if (!(arguments instanceof Map)) {
            result.error(ERROR_INVALID_ARGS, MSG_ARGS_MUST_BE_MAP, null);
            return;
        }

        scanDocApi = new ScanDocApi(scanDocApiOptionsFromJson((Map<String, Object>) arguments));

        result.success(null);
    }

    private void extractScannedCard(final Object arguments, final Result result) {

        if (!(arguments instanceof Map)) {
            result.error(ERROR_INVALID_ARGS, MSG_ARGS_MUST_BE_MAP, null);
            return;
        }

        final Map<String, Object> args = (Map<String, Object>) arguments;

        final String base64 = (String) args.get(KEY_BASE64_IMG);

        if (base64 == null) {
            result.error(ERROR_INVALID_IMAGE, MSG_MISSING_BASE64_IMG, null);
            return;
        }

        final Bitmap bitmap = base64ToBitmap(base64);

        if (bitmap == null) {
            result.error(ERROR_INVALID_IMAGE, MSG_FAILED_DECODE_BITMAP, null);
            return;
        }

        final ResultCallback<ExtractionResponse> callback = new ResultCallback<ExtractionResponse>() {
            @Override
            public void onSuccess(final ExtractionResponse response) {
                result.success(extractionResponseToJson(response));
            }

            @Override
            public void onError(final Throwable error) {
                result.error(ERROR_EXTRACTION, error.getMessage(), null);
            }
        };

        Object configuration = args.get(KEY_CONFIGURATION);
        if (configuration instanceof Map) {
            final ExtractionConfiguration config =
                    extractionConfigurationFromJson((Map<String, Object>) configuration);

            scanDocApi.extractDataFromScannedCard(bitmap, config, callback);
        } else {
            scanDocApi.extractDataFromScannedCard(bitmap, callback);
        }
    }

    private void validateScannedCard(final Object arguments, final Result result) {

        if (!(arguments instanceof Map)) {
            result.error(ERROR_INVALID_ARGS, MSG_ARGS_MUST_BE_MAP, null);
            return;
        }

        final Map<String, Object> args = (Map<String, Object>) arguments;

        final List<String> base64Images = (List<String>) args.get(KEY_BASE64_IMGS);
        if (base64Images == null || base64Images.isEmpty()) {
            result.error(ERROR_INVALID_IMAGES, MSG_MISSING_BASE64_IMGS, null);
            return;
        }

        final List<Bitmap> bitmapList = new ArrayList<>();
        for (final String img : base64Images) {
            bitmapList.add(base64ToBitmap(img));
        }

        final Bitmap[] bitmaps = bitmapList.toArray(new Bitmap[0]);

        final ValidationConfiguration config;

        Object configuration = args.get(KEY_CONFIGURATION);
        if (configuration instanceof Map) {
            config = validationConfigurationFromJson(
                    (Map<String, Object>) configuration
            );
        } else {
            config = new ValidationConfiguration();
        }

        scanDocApi.validateScannedCard(bitmaps, config, new ResultCallback<ValidationResponse>() {
            @Override
            public void onSuccess(final ValidationResponse response) {
                result.success(validationResponseToJson(response));
            }

            @Override
            public void onError(final Throwable error) {
                result.error(ERROR_VALIDATION, error.getMessage(), null);
            }
        });
    }

}
