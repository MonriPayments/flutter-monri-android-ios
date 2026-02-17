import Flutter
import PassKit
import UIKit
import Monri
import WebKit

public class SwiftMonriPaymentsPlugin: NSObject, FlutterPlugin {
    public static var _registrar: FlutterPluginRegistrar!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: PluginKeys.channelName,
            binaryMessenger: registrar.messenger()
        )
        let instance = SwiftMonriPaymentsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        _registrar = registrar;
    }
    
    var rootViewController : UIViewController{
        return UIApplication.shared.keyWindow!.rootViewController!
    }
    
    var monri: MonriApi!
    var scanDocApi: ScanDocApi?
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch(call.method) {
            
        case PluginKeys.confirmPayment:
            confirmPayment(call.arguments, result)
            
        case PluginKeys.confirmApplePayment:
            confirmPayment(call.arguments, result)
            
        case PluginKeys.initScanDoc:
            initScanDoc(args: call.arguments as! [String: Any], result: result)
            
        case PluginKeys.extractScannedCard:
            extractScannedCard(args: call.arguments as! [String: Any], result: result)
            
        case PluginKeys.validateScannedCard:
            validateScannedCard(args: call.arguments as! [String: Any], result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func buildFlutterConfirmPaymentParams(_ arguments: Any?) throws -> FlutterConfirmPaymentParams  {
        let request = arguments as! Dictionary<String, AnyObject?>
        
        if let _ = request[PluginKeys.card] {
            return FlutterConfirmPaymentParams.forCard(request: request)
        }
        
        if let _ = request[PluginKeys.savedCard] {
            return FlutterConfirmPaymentParams.forSavedCard(request: request)
        }
        
        if let _ = request[PluginKeys.applePayMerchantID] {
            return FlutterConfirmPaymentParams.forApplePay(request: request)
        }
        
        throw ConfigurationError.unsupportedPaymentMethod
    }
    
    func confirmPayment(_ arguments: Any?, _ result: @escaping FlutterResult) {
        do {
            let params = try buildFlutterConfirmPaymentParams(arguments)
            
            // Log tokenization request if present
            if let card = params.card {
                // Safely log masked PAN (first 6 + last 4 digits)
                let maskedPan = maskPan(card.pan)
            } else if let savedCard = params.savedCard {
            }
            
            let confirmPaymentParams = params.confirmPaymentParams()
            let monriOptions = params.monriApiOptions()
            
            writeMetaData()
            
            self.monri = MonriApi(rootViewController, options: monriOptions);
            
            let customisation = getApplePayCustomisation(flutterApplePayment: params.flutterApplePayment)
            
            monri.confirmPayment(confirmPaymentParams, applePayCustomisation: customisation, { [result] confirmPayment in
                switch confirmPayment {
                case .result(let paymentResult):
                    result([PluginKeys.status : PluginKeys.statusResult,
                            PluginKeys.data : paymentResult.toJSON()])
                case .declined(let confirmPaymentDeclined):
                    result([PluginKeys.status : PluginKeys.statusDeclined,
                            PluginKeys.data : confirmPaymentDeclined.status])
                case .error(let error):
                    if let nsError = error as NSError? {
                    }
                    result([PluginKeys.status : PluginKeys.statusError,
                            PluginKeys.data : [PluginKeys.error : error.localizedDescription]])
                case .pending:
                    result([PluginKeys.status : PluginKeys.statusPending])
                }
            })
        } catch let error as ConfigurationError {
            result([PluginKeys.error :
                        "Unsupported payment method, 'card' or 'saved_card' not found",
                    PluginKeys.status: PluginKeys.statusError])
        } catch let error {
            result([PluginKeys.error :
                        "An error occurred on confirmPayment - \(error)",
                    PluginKeys.status: PluginKeys.statusError])
        }
    }
    
    private func writeMetaData() {
        let version: String = Bundle(identifier: PluginKeys.monriBundleId)?.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        
        let defaults = UserDefaults.standard
        defaults.set("iOS-SDK:Flutter:\(version)", forKey: PluginKeys.monriMetaLibrary)
    }
    
    private func getApplePayCustomisation(flutterApplePayment: FlutterApplePayment?) -> (PKPaymentButtonType, PKPaymentButtonStyle)? {
        
        guard let params = flutterApplePayment,
              let style = params.pkPaymentButtonStyle,
              let type = params.pkPaymentButtonType else {
            return nil
        }
        
        return (type, style)
        
    }
    
    private func initScanDoc(args: [String: Any], result: @escaping FlutterResult) {
        
        guard let baseUrl = args[PluginKeys.scanDocApiBaseUrl] as? String,
              let userKey = args[PluginKeys.scanDocUserKey] as? String,
              let subClient = args[PluginKeys.scanDocSubKey] as? String,
              let acceptTermsAndConditions =
                args[PluginKeys.acceptTermsAndConditions] as? Bool
        else {
            result([PluginKeys.error :
                        PluginKeys.invalidArgumentsMessage,
                    PluginKeys.status: PluginKeys.statusError])
            return
        }
        
        self.scanDocApi = ScanDocApi(options: ScanDocApiOptions(scanDocApiBaseUrl: baseUrl,
                                                                userKey: userKey,
                                                                subClient: subClient,
                                                                acceptTermsAndConditions: acceptTermsAndConditions))
        
        result(nil)
        
    }
    
    private func extractScannedCard(args: [String: Any], result: @escaping FlutterResult) {
        guard let base64 = args[PluginKeys.base64Img] as? String,
              let imageData = Data(base64Encoded: base64),
              let uiImage = UIImage(data: imageData) else {
            result(FlutterError(
                code: PluginKeys.invalidImage,
                message: PluginKeys.invalidImageMessage,
                details: nil))
            return
        }

        var config: ExtractionConfiguration? = nil
        
        if let configDict = args[PluginKeys.configuration] as? [String: Any] {
            config = ExtractionConfiguration.fromJson(json: configDict)
        }

        guard let scanDocApi = scanDocApi else {
            result(FlutterError(
                code: PluginKeys.notInitialized,
                message: PluginKeys.notInitialized,
                details: nil))
            return
        }
        
        scanDocApi.extractDataFromScannedCard(scannedCardImage: uiImage, extractionConfiguration: config) { res in
            switch res {
            case .success(let response):
                result(response.toJson())
            case .failure(let error):
                result(FlutterError(code: PluginKeys.extractionFailed, message: error.localizedDescription, details: nil))
            }
        }
    }
    
    private func validateScannedCard(args: [String: Any], result: @escaping FlutterResult) {
        
        guard let base64Array = args[PluginKeys.base64Imgs] as? [String] else {
            result(FlutterError(
                code: PluginKeys.invalidImages,
                message: PluginKeys.invalidArgumentsMessage,
                details: nil))
            return
        }

        let images: [UIImage] = base64Array.compactMap { str in
            if let data = Data(base64Encoded: str) {
                return UIImage(data: data)
            }
            return nil
        }
        
        var config: ValidationConfiguration? = nil
        
        if let configDict = args[PluginKeys.configuration] as? [String: Any] {
            config = ValidationConfiguration.fromJson(json: configDict)
        }

        guard let scanDocApi = scanDocApi else {
            result(FlutterError(
                code: PluginKeys.notInitialized,
                message: PluginKeys.notInitializedMessage,
                details: nil))
            return
        }
        
        scanDocApi.validateScannedCard(scannedCardImages: images, validationConfiguration: config) { res in
            switch res {
            case .success(let response):
                result(response.toJson())
            case .failure(let error):
                result(FlutterError(code: PluginKeys.validationFailed, message: error.localizedDescription, details: nil))
            }
        }
    }
    
}

enum ConfigurationError: Error {
    case unsupportedPaymentMethod
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}

// Helper function to mask card PAN
private func maskPan(_ pan: String) -> String {
    if pan.count > 10 {
        let prefix = pan.prefix(6)
        let suffix = pan.suffix(4)
        return "\(prefix)******\(suffix)"
    } else {
        return "********" // Too short to properly mask
    }
}
