import Flutter
import UIKit
import Monri

extension ExtractionConfiguration {
    
    static func fromJson(json: [String: Any]) -> ExtractionConfiguration? {
        
        guard
            let imageConfiguration = json[JsonKeys.imageConfiguration] as? [String: Any],
            let imageCropped = imageConfiguration[JsonKeys.imageCropped] as? Bool,
            let extractionConfig = json[JsonKeys.extractionConfigurationSettings] as? [String: Any],
            let shouldReturnDocumentImage = extractionConfig[JsonKeys.shouldReturnDocumentImage] as? Bool,
            let skipDocumentSizeCheck = extractionConfig[JsonKeys.skipDocumentSizeCheck] as? Bool,
            let skipImageSizeCheck = extractionConfig[JsonKeys.skipImageSizeCheck] as? Bool,
            let canStoreImages = extractionConfig[JsonKeys.canStoreImages] as? Bool,
            let dontUseValidation = extractionConfig[JsonKeys.dontUseValidation] as? Bool
        else {
            return nil
        }
        
        return ExtractionConfiguration(
            imageConfiguration: ImageConfiguration(imageCropped: imageCropped),
            extractionSettings: ExtractionConfigurationSettings(
                shouldReturnDocumentImage: shouldReturnDocumentImage,
                skipDocumentSizeCheck: skipDocumentSizeCheck,
                skipImageSizeCheck: skipImageSizeCheck,
                canStoreImages: canStoreImages,
                dontUseValidation: dontUseValidation
            ),
            acceptTermsAndConditions: true
        )
    }
}

extension ValidationConfiguration {
    
    static func fromJson(json: [String: Any]) -> ValidationConfiguration? {
        
        guard
            let blurValues = json[JsonKeys.blurValues] as? [Double],
            let validationSettings = json[JsonKeys.validationSettings] as? [String: Any],
            let skipImageSizeCheck = validationSettings[JsonKeys.skipImageSizeCheck] as? Bool
        else {
            return nil
        }
        
        return ValidationConfiguration(
            blurValues: blurValues,
            validationSettings: ValidationConfigurationSettings(
                skipImageSizeCheck: skipImageSizeCheck
            )
        )
    }
}

extension ExtractionResponse {
    
    func toJson() -> [String: Any] {
        
        var json: [String: Any] = [
            JsonKeys.transactionID: self.transactionID ?? "",
            JsonKeys.uploadedAt: self.uploadedAt ?? "",
            JsonKeys.productName: self.productName ?? "",
            JsonKeys.errors: self.errors ?? [],
            JsonKeys.warnings: self.warnings ?? [],
            JsonKeys.status: self.status ?? 0,
            JsonKeys.method: self.method ?? "",
            JsonKeys.infoCode: self.infoCode ?? "",
            JsonKeys.analysisTime: self.analysisTime ?? 0.0,
            JsonKeys.os: self.os ?? "",
            JsonKeys.browser: self.browser ?? "",
            JsonKeys.device: self.device ?? ""
        ]
        
        if let data = self.data {
            json[JsonKeys.data] = [
                JsonKeys.holdersName: data.holdersName ?? "",
                JsonKeys.luhnCheck: data.luhnCheck ?? "",
                JsonKeys.cardNumber: data.cardNumber ?? "",
                JsonKeys.expiryDate: data.expiryDate ?? "",
                JsonKeys.extractedTexts: data.extractedTexts ?? "",
                JsonKeys.iban: data.iban ?? "",
                JsonKeys.issuedDate: data.issuedDate ?? ""
            ]
        }
        
        if let imageData = imageData {
            json[JsonKeys.imageData] = [
                JsonKeys.creditCardImage: imageData.creditCardImage
            ]
        }
        
        return json
    }
}

extension ScanDocValidationResponse {
    
    func toJson() -> [String: Any] {
        
        return [
            JsonKeys.transactionID: self.transactionID ?? "",
            JsonKeys.uploadedAt: self.uploadedAt ?? "",
            JsonKeys.productName: self.productName ?? "",
            JsonKeys.errors: self.errors ?? [],
            JsonKeys.warnings: self.warnings ?? [],
            JsonKeys.status: self.status ?? 0,
            JsonKeys.method: self.method ?? "",
            JsonKeys.infoCode: self.infoCode ?? "",
            JsonKeys.analysisTime: self.analysisTime ?? 0.0,
            JsonKeys.keypoints: self.keypoints ?? [],
            JsonKeys.validated: self.validated ?? false,
            JsonKeys.index: self.index ?? 0,
            JsonKeys.info: self.info ?? ""
        ]
    }
}
