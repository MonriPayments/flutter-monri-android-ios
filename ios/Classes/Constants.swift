import Foundation

enum PluginKeys {
    
    // Channel
    static let channelName = "MonriPayments"
    
    // Method names
    static let confirmPayment = "confirmPayment"
    static let confirmApplePayment = "confirmApplePayment"
    static let initScanDoc = "initScanDoc"
    static let extractScannedCard = "extractScannedCard"
    static let validateScannedCard = "validateScannedCard"
    
    // Payment request keys
    static let card = "card"
    static let savedCard = "saved_card"
    static let applePayMerchantID = "applePayMerchantID"
    
    // ScanDoc init args
    static let scanDocApiBaseUrl = "scanDocApiBaseUrl"
    static let scanDocUserKey = "scanDocUserKey"
    static let scanDocSubKey = "scanDocSubKey"
    static let acceptTermsAndConditions = "acceptTermsAndConditions"
    
    // ScanDoc extract args
    static let base64Img = "base64Img"
    static let configuration = "configuration"
    
    // ScanDoc validate args
    static let base64Imgs = "base64Imgs"
    
    // Result keys
    static let status = "status"
    static let data = "data"
    static let error = "error"
    
    // Status values
    static let statusResult = "result"
    static let statusDeclined = "declined"
    static let statusError = "error"
    static let statusPending = "pending"
    
    // Error codes
    static let invalidImage = "INVALID_IMAGE"
    static let notInitialized = "NOT_INITIALIZED"
    static let extractionFailed = "EXTRACTION_FAILED"
    static let validationFailed = "VALIDATION_FAILED"
    static let invalidImages = "INVALID_IMAGES"
    
    // Error messages
    static let invalidArgumentsMessage = "Unable to parse arguments for ScanDocApiOptions"
    static let invalidImageMessage = "Base64 image is invalid"
    static let notInitializedMessage = "Scan Doc is not initialized"
    
    // Metadata
    static let monriMetaLibrary = "com.monri.meta.library"
    static let monriBundleId = "org.cocoapods.MonriPayments"
}

enum JsonKeys {
    
    // Common
    static let transactionID = "TransactionID"
    static let uploadedAt = "UploadedAt"
    static let productName = "ProductName"
    static let errors = "Errors"
    static let warnings = "Warnings"
    static let status = "Status"
    static let method = "Method"
    static let infoCode = "InfoCode"
    static let analysisTime = "AnalysisTime"
    static let os = "OS"
    static let browser = "Browser"
    static let device = "Device"
    
    // Extraction Data
    static let data = "Data"
    static let holdersName = "HoldersName"
    static let luhnCheck = "LuhnCheck"
    static let cardNumber = "CardNumber"
    static let expiryDate = "ExpiryDate"
    static let extractedTexts = "ExtractedTexts"
    static let iban = "IBAN"
    static let issuedDate = "IssuedDate"
    
    // Image
    static let imageData = "ImageData"
    static let creditCardImage = "CreditCardImage"
    
    // Extraction Config
    static let imageConfiguration = "imageConfiguration"
    static let imageCropped = "imageCropped"
    static let extractionConfigurationSettings = "extractionConfigurationSettings"
    static let shouldReturnDocumentImage = "shouldReturnDocumentImage"
    static let skipDocumentSizeCheck = "skipDocumentSizeCheck"
    static let skipImageSizeCheck = "skipImageSizeCheck"
    static let canStoreImages = "canStoreImages"
    static let dontUseValidation = "dontUseValidation"
    
    // Validation Config
    static let blurValues = "blurValues"
    static let validationSettings = "validationSettings"
    
    // Validation Response
    static let keypoints = "Keypoints"
    static let validated = "Validated"
    static let index = "Index"
    static let info = "Info"
}
