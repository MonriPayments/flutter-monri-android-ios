package com.monri.flutter;

import com.monri.android.ExtractionConfiguration;
import com.monri.android.ExtractionSettings;
import com.monri.android.ImageConfiguration;
import com.monri.android.ValidationConfiguration;
import com.monri.android.ValidationSettings;
import com.monri.android.model.ExtractionResponse;
import com.monri.android.model.ScanDocApiOptions;
import com.monri.android.model.ValidationResponse;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

class ScanDocHelpers {

    private static final String KEY_SCAN_DOC_API_BASE_URL = "scanDocApiBaseUrl";
    private static final String KEY_SCAN_DOC_USER_KEY = "scanDocUserKey";
    private static final String KEY_SCAN_DOC_SUB_KEY = "scanDocSubKey";
    private static final String KEY_ACCEPT_TERMS = "acceptTermsAndConditions";

    private static final String KEY_BLUR_VALUES = "blurValues";
    private static final String KEY_VALIDATION_SETTINGS = "validationSettings";
    private static final String KEY_SKIP_IMAGE_SIZE_CHECK = "skipImageSizeCheck";

    private static final String KEY_IMAGE_CONFIGURATION = "imageConfiguration";
    private static final String KEY_IMAGE_CROPPED = "imageCropped";

    private static final String KEY_EXTRACTION_CONFIGURATION_SETTINGS = "extractionConfigurationSettings";
    private static final String KEY_SHOULD_RETURN_DOCUMENT_IMAGE = "shouldReturnDocumentImage";
    private static final String KEY_SKIP_DOCUMENT_SIZE_CHECK = "skipDocumentSizeCheck";
    private static final String KEY_CAN_STORE_IMAGES = "canStoreImages";
    private static final String KEY_DONT_USE_VALIDATION = "dontUseValidation";

    private static final String KEY_TRANSACTION_ID = "TransactionID";
    private static final String KEY_UPLOADED_AT = "UploadedAt";
    private static final String KEY_PRODUCT_NAME = "ProductName";
    private static final String KEY_ERRORS = "Errors";
    private static final String KEY_WARNINGS = "Warnings";
    private static final String KEY_STATUS = "Status";
    private static final String KEY_METHOD = "Method";
    private static final String KEY_INFO_CODE = "InfoCode";
    private static final String KEY_ANALYSIS_TIME = "AnalysisTime";
    private static final String KEY_VALIDATED = "Validated";
    private static final String KEY_KEYPOINTS = "Keypoints";
    private static final String KEY_DETECTED_BLUR_VALUE = "DetectedBlurValue";
    private static final String KEY_INDEX = "Index";
    private static final String KEY_INFO = "Info";

    private static final String KEY_OS = "OS";
    private static final String KEY_BROWSER = "Browser";
    private static final String KEY_DEVICE = "Device";

    private static final String KEY_DATA = "Data";
    private static final String KEY_HOLDERS_NAME = "HoldersName";
    private static final String KEY_LUHN_CHECK = "LuhnCheck";
    private static final String KEY_CARD_NUMBER = "CardNumber";
    private static final String KEY_EXPIRY_DATE = "ExpiryDate";
    private static final String KEY_EXTRACTED_TEXTS = "ExtractedTexts";
    private static final String KEY_IBAN = "IBAN";
    private static final String KEY_ISSUED_DATE = "IssuedDate";

    private static final String KEY_IMAGE_DATA = "ImageData";
    private static final String KEY_CREDIT_CARD_IMAGE = "CreditCardImage";

    static ScanDocApiOptions scanDocApiOptionsFromJson(Map<String, Object> json) {
        return new ScanDocApiOptions(
                (String) json.get(KEY_SCAN_DOC_API_BASE_URL),
                (String) json.get(KEY_SCAN_DOC_USER_KEY),
                (String) json.get(KEY_SCAN_DOC_SUB_KEY),
                (boolean) json.get(KEY_ACCEPT_TERMS)
        );
    }

    static ValidationConfiguration validationConfigurationFromJson(Map<String, Object> json) {
        if (json == null) return null;

        final List<Double> blurValues = (List<Double>) json.get(KEY_BLUR_VALUES);

        final Map<String, Object> settingsMap =
                (Map<String, Object>) json.get(KEY_VALIDATION_SETTINGS);

        final Boolean skipImageSizeCheck =
                (Boolean) settingsMap.get(KEY_SKIP_IMAGE_SIZE_CHECK);

        final ValidationSettings settings = new ValidationSettings(skipImageSizeCheck);

        return new ValidationConfiguration(settings, blurValues);
    }

    static Map<String, Object> validationResponseToJson(ValidationResponse response) {
        final Map<String, Object> json = new HashMap<>();

        json.put(KEY_TRANSACTION_ID, response.getTransactionID());
        json.put(KEY_UPLOADED_AT, response.getUploadedAt());
        json.put(KEY_PRODUCT_NAME, response.getProductName());
        json.put(KEY_ERRORS, response.getErrors());
        json.put(KEY_WARNINGS, response.getWarnings());
        json.put(KEY_STATUS, response.getStatus());
        json.put(KEY_METHOD, response.getMethod());
        json.put(KEY_INFO_CODE, response.getInfoCode());
        json.put(KEY_ANALYSIS_TIME, response.getAnalysisTime());
        json.put(KEY_VALIDATED, response.isValidated());
        json.put(KEY_KEYPOINTS, response.getKeypoints());
        json.put(KEY_DETECTED_BLUR_VALUE, response.getDetectedBlurValue());
        json.put(KEY_INDEX, response.getIndex());
        json.put(KEY_INFO, response.getInfo());

        return json;
    }

    static Map<String, Object> extractionResponseToJson(ExtractionResponse response) {
        final Map<String, Object> json = new HashMap<>();

        json.put(KEY_TRANSACTION_ID, response.getTransactionID());
        json.put(KEY_UPLOADED_AT, response.getUploadedAt());
        json.put(KEY_PRODUCT_NAME, response.getProductName());
        json.put(KEY_ERRORS, response.getErrors());
        json.put(KEY_WARNINGS, response.getWarnings());
        json.put(KEY_STATUS, response.getStatus());
        json.put(KEY_METHOD, response.getMethod());
        json.put(KEY_INFO_CODE, response.getInfoCode());
        json.put(KEY_ANALYSIS_TIME, response.getAnalysisTime());
        json.put(KEY_OS, response.getOsInfo());
        json.put(KEY_BROWSER, response.getBrowserInfo());
        json.put(KEY_DEVICE, response.getDeviceInfo());

        if (response.getCardData() != null) {
            final Map<String, Object> data = new HashMap<>();
            data.put(KEY_HOLDERS_NAME, response.getCardData().getHoldersName());
            data.put(KEY_LUHN_CHECK, response.getCardData().getLuhnCheck());
            data.put(KEY_CARD_NUMBER, response.getCardData().getCardNumber());
            data.put(KEY_EXPIRY_DATE, response.getCardData().getExpiryDate());
            data.put(KEY_EXTRACTED_TEXTS, response.getCardData().getExtractedTexts());
            data.put(KEY_IBAN, response.getCardData().getIBAN());
            data.put(KEY_ISSUED_DATE, response.getCardData().getIssuedDate());

            json.put(KEY_DATA, data);
        } else {
            json.put(KEY_DATA, null);
        }

        if (response.getBase64CreditCardImage() != null) {
            final Map<String, Object> imageData = new HashMap<>();
            imageData.put(KEY_CREDIT_CARD_IMAGE, response.getBase64CreditCardImage());
            json.put(KEY_IMAGE_DATA, imageData);
        } else {
            json.put(KEY_IMAGE_DATA, null);
        }

        return json;
    }

    static ExtractionConfiguration extractionConfigurationFromJson(Map<String, Object> json) {
        if (json == null) return null;

        final Map<String, Object> imageConfigMap =
                (Map<String, Object>) json.get(KEY_IMAGE_CONFIGURATION);

        assert imageConfigMap != null;
        final Boolean imageCropped = (Boolean) imageConfigMap.get(KEY_IMAGE_CROPPED);

        final ImageConfiguration imageConfiguration =
                new ImageConfiguration(ExtractionConfiguration.ImageType.BASE64, Boolean.TRUE.equals(imageCropped));

        final Map<String, Object> settingsMap =
                (Map<String, Object>) json.get(KEY_EXTRACTION_CONFIGURATION_SETTINGS);

        final Boolean shouldReturnDocumentImage =
                (Boolean) settingsMap.get(KEY_SHOULD_RETURN_DOCUMENT_IMAGE);
        final Boolean skipDocumentSizeCheck =
                (Boolean) settingsMap.get(KEY_SKIP_DOCUMENT_SIZE_CHECK);
        final Boolean skipImageSizeCheck =
                (Boolean) settingsMap.get(KEY_SKIP_IMAGE_SIZE_CHECK);
        final Boolean canStoreImages =
                (Boolean) settingsMap.get(KEY_CAN_STORE_IMAGES);
        final Boolean dontUseValidation =
                (Boolean) settingsMap.get(KEY_DONT_USE_VALIDATION);

        final ExtractionSettings settings = new ExtractionSettings.Builder()
                .setCanStoreImages(Boolean.TRUE.equals(canStoreImages))
                .setShouldReturnDocumentImage(Boolean.TRUE.equals(shouldReturnDocumentImage))
                .setDontUseValidation(Boolean.TRUE.equals(dontUseValidation))
                .setSkipDocumentSizeCheck(Boolean.TRUE.equals(skipDocumentSizeCheck))
                .setSkipImageSizeCheck(Boolean.TRUE.equals(skipImageSizeCheck))
                .build();

        return new ExtractionConfiguration(imageConfiguration, settings);
    }
}
