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

    static ScanDocApiOptions scanDocApiOptionsFromJson(Map<String, Object> json) {
        return new ScanDocApiOptions(
                (String) json.get("scanDocApiBaseUrl"),
                (String) json.get("scanDocUserKey"),
                (String) json.get("scanDocSubKey"),
                (boolean) json.get("acceptTermsAndConditions")
        );
    }

    static ValidationConfiguration validationConfigurationFromJson(Map<String, Object> json) {
        if (json == null) return null;

        List<Double> blurValues = (List<Double>) json.get("blurValues");

        Map<String, Object> settingsMap =
                (Map<String, Object>) json.get("validationSettings");

        Boolean skipImageSizeCheck =
                (Boolean) settingsMap.get("skipImageSizeCheck");

        ValidationSettings settings = new ValidationSettings(skipImageSizeCheck);

        return new ValidationConfiguration(settings, blurValues);
    }

    static Map<String, Object> validationResponseToJson(ValidationResponse response) {
        Map<String, Object> json = new HashMap<>();

        json.put("TransactionID", response.getTransactionID());
        json.put("UploadedAt", response.getUploadedAt());
        json.put("ProductName", response.getProductName());
        json.put("Errors", response.getErrors());
        json.put("Warnings", response.getWarnings());
        json.put("Status", response.getStatus());
        json.put("Method", response.getMethod());
        json.put("InfoCode", response.getInfoCode());
        json.put("AnalysisTime", response.getAnalysisTime());
        json.put("Validated", response.isValidated());
        json.put("Keypoints", response.getKeypoints());
        json.put("DetectedBlurValue", response.getDetectedBlurValue());
        json.put("Index", response.getIndex());
        json.put("Info", response.getInfo());

        return json;
    }


    static Map<String, Object> extractionResponseToJson(ExtractionResponse response) {
        Map<String, Object> json = new HashMap<>();

        json.put("TransactionID", response.getTransactionID());
        json.put("UploadedAt", response.getUploadedAt());
        json.put("ProductName", response.getProductName());
        json.put("Errors", response.getErrors());
        json.put("Warnings", response.getWarnings());
        json.put("Status", response.getStatus());
        json.put("Method", response.getMethod());
        json.put("InfoCode", response.getInfoCode());
        json.put("AnalysisTime", response.getAnalysisTime());
        json.put("OS", response.getOsInfo());
        json.put("Browser", response.getBrowserInfo());
        json.put("Device", response.getDeviceInfo());

        if (response.getCardData() != null) {
            Map<String, Object> data = new HashMap<>();

            data.put("HoldersName", response.getCardData().getHoldersName());
            data.put("LuhnCheck", response.getCardData().getLuhnCheck());
            data.put("CardNumber", response.getCardData().getCardNumber());
            data.put("ExpiryDate", response.getCardData().getExpiryDate());
            data.put("ExtractedTexts", response.getCardData().getExtractedTexts());
            data.put("IBAN", response.getCardData().getIBAN());
            data.put("IssuedDate", response.getCardData().getIssuedDate());

            json.put("Data", data);
        } else {
            json.put("Data", null);
        }

        if (response.getBase64CreditCardImage() != null) {
            Map<String, Object> imageData = new HashMap<>();
            imageData.put("CreditCardImage", response.getBase64CreditCardImage());
            json.put("ImageData", imageData);
        } else {
            json.put("ImageData", null);
        }

        return json;
    }

    static ExtractionConfiguration extractionConfigurationFromJson(Map<String, Object> json) {
        if (json == null) return null;

        Map<String, Object> imageConfigMap =
                (Map<String, Object>) json.get("imageConfiguration");

        assert imageConfigMap != null;
        Boolean imageCropped = (Boolean) imageConfigMap.get("imageCropped");

        ImageConfiguration imageConfiguration =
                new ImageConfiguration(ExtractionConfiguration.ImageType.BASE64, Boolean.TRUE.equals(imageCropped));

        Map<String, Object> settingsMap =
                (Map<String, Object>) json.get("extractionConfigurationSettings");

        Boolean shouldReturnDocumentImage =
                (Boolean) settingsMap.get("shouldReturnDocumentImage");
        Boolean skipDocumentSizeCheck =
                (Boolean) settingsMap.get("skipDocumentSizeCheck");
        Boolean skipImageSizeCheck =
                (Boolean) settingsMap.get("skipImageSizeCheck");
        Boolean canStoreImages =
                (Boolean) settingsMap.get("canStoreImages");
        Boolean dontUseValidation =
                (Boolean) settingsMap.get("dontUseValidation");

        ExtractionSettings settings = new ExtractionSettings.Builder()
                .setCanStoreImages(canStoreImages != null && canStoreImages)
                .setShouldReturnDocumentImage(shouldReturnDocumentImage != null && shouldReturnDocumentImage)
                .setDontUseValidation(dontUseValidation != null && dontUseValidation)
                .setSkipDocumentSizeCheck(skipDocumentSizeCheck != null && skipDocumentSizeCheck)
                .setSkipImageSizeCheck(skipImageSizeCheck != null && skipImageSizeCheck).build();

        return new ExtractionConfiguration(imageConfiguration, settings);
    }
}
