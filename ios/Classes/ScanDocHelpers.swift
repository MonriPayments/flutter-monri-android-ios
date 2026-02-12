import Flutter
import UIKit
import Monri

extension ExtractionConfiguration {
    
    static func fromJson(json: [String: Any]) -> ExtractionConfiguration? {
        
        guard let imageConfiguration = json["imageConfiguration"] as? [String: Any],
            let imageCropped = imageConfiguration["imageCropped"] as? Bool,
              let extractionConfig = json["extractionConfigurationSettings"] as? [String: Any],
              let shouldReturnDocumentImage = extractionConfig["shouldReturnDocumentImage"] as? Bool,
              let skipDocumentSizeCheck = extractionConfig["skipDocumentSizeCheck"] as? Bool,
              let skipImageSizeCheck = extractionConfig["skipImageSizeCheck"] as? Bool,
              let canStoreImages = extractionConfig["canStoreImages"] as? Bool,
              let dontUseValidation = extractionConfig["dontUseValidation"] as? Bool
        else {
            return nil
        }
        
        return ExtractionConfiguration(imageConfiguration: ImageConfiguration(imageCropped: imageCropped),
                                       extractionSettings: ExtractionConfigurationSettings(shouldReturnDocumentImage: shouldReturnDocumentImage,
                                                                        skipDocumentSizeCheck: skipDocumentSizeCheck,
                                                                        skipImageSizeCheck: skipImageSizeCheck,
                                                                        canStoreImages: canStoreImages,
                                                                        dontUseValidation: dontUseValidation),
                                       acceptTermsAndConditions: true)
    }
}

extension ValidationConfiguration {
    
    static func fromJson(json: [String: Any]) -> ValidationConfiguration? {
        
        guard let blurValues = json["blurValues"] as? [Double],
              let validationSettings = json["validationSettings"] as? [String: Any],
              let skipImageSizeCheck = validationSettings["skipImageSizeCheck"] as? Bool
        else {
            return nil
        }
        
        return ValidationConfiguration(blurValues: blurValues,
                                       validationSettings: ValidationConfigurationSettings(skipImageSizeCheck: skipImageSizeCheck),
                                       acceptTermsAndConditions: true)
    }
}

extension ExtractionResponse {
    
    func toJson() -> [String: Any] {
        
        var json: [String: Any] = [
            "TransactionID": self.transactionID ?? "",
            "UploadedAt": self.uploadedAt ?? "",
            "ProductName": self.productName ?? "",
            "Errors": self.errors ?? [],
            "Warnings": self.warnings ?? [],
            "Status": self.status ?? 0,
            "Method": self.method ?? "",
            "InfoCode": self.infoCode ?? "",
            "AnalysisTime": self.analysisTime ?? 0.0,
            "OS": self.os ?? "",
            "Browser": self.browser ?? "",
            "Device": self.device ?? ""
        ]
        
        if let data = self.data {
            json["Data"] = [
                "HoldersName": data.holdersName ?? "",
                "LuhnCheck": data.luhnCheck ?? "",
                "CardNumber": data.cardNumber ?? "",
                "ExpiryDate": data.expiryDate ?? "",
                "ExtractedTexts": data.extractedTexts ?? "",
                "IBAN": data.iban ?? "",
                "IssuedDate": data.issuedDate ?? ""
            ]
        }
        if let imageData = imageData {
            json["ImageData"] = [
                "CreditCardImage": self.imageData?.creditCardImage
            ]
        }
        return json
    }
}

extension ScanDocValidationResponse {
    
    func toJson() -> [String: Any] {
        
        var json: [String: Any] = [
            "TransactionID": self.transactionID ?? "",
            "UploadedAt": self.uploadedAt ?? "",
            "ProductName": self.productName ?? "",
            "Errors": self.errors ?? [],
            "Warnings": self.warnings ?? [],
            "Status": self.status ?? 0,
            "Method": self.method ?? "",
            "InfoCode": self.infoCode ?? "",
            "AnalysisTime": self.analysisTime ?? 0.0,
            "Keypoints": self.keypoints ?? [],
            "Validated": self.validated ?? false,
            "Index": self.index ?? 0,
            "Info": self.info ?? ""
        ]
        
        return json
    }
}
