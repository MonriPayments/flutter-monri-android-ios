import Flutter
import PassKit
import UIKit
import Monri
import WebKit

public class SwiftMonriPaymentsPlugin: NSObject, FlutterPlugin {
    public static var _registrar: FlutterPluginRegistrar!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "MonriPayments", binaryMessenger: registrar.messenger())
        let instance = SwiftMonriPaymentsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        _registrar = registrar;
    }
    
    var rootViewController : UIViewController{
        return UIApplication.shared.keyWindow!.rootViewController!
    }
    
    var monri: MonriApi!
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch(call.method){
            
        case "confirmPayment" : confirmPayment(call.arguments, result)
        case "confirmApplePayment": confirmPayment(call.arguments, result)
        default : result(FlutterMethodNotImplemented);
        }
    }
    
    private func buildFlutterConfirmPaymentParams(_ arguments: Any?) throws -> FlutterConfirmPaymentParams  {
        let request = arguments as! Dictionary<String, AnyObject?>
        
        if let _ = request["card"] {
            return FlutterConfirmPaymentParams.forCard(request: request)
        }
        
        if let _ = request["saved_card"] {
            return FlutterConfirmPaymentParams.forSavedCard(request: request)
        }
        
        if let _ = request["applePayMerchantID"] {
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
                    result(["status" : "result", "data" : paymentResult.toJSON()]);
                case .declined(let confirmPaymentDeclined):
                    result(["status" : "declined", "data" : confirmPaymentDeclined.status]);
                case .error(let error):
                    if let nsError = error as NSError? {
                    }
                    result(["status" : "error", "data": ["error": error.localizedDescription]]);
                case .pending:
                    result(["status" : "pending"]);
                }
            })
        } catch let error as ConfigurationError {
            result(["error" : "Unsupported payment method, 'card' or 'saved_card' not found", "status": "error"]);
        } catch let error {
            result(["error" : "An error occurred on confirmPayment - \(error)", "status": "error"]);
        }
    }
    
    private func writeMetaData(){
        let version: String = Bundle(identifier: "org.cocoapods.MonriPayments")?.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        
        let defaults = UserDefaults.standard
        defaults.set("iOS-SDK:Flutter:\(version)", forKey: "com.monri.meta.library")
    }
    
    private func getApplePayCustomisation(flutterApplePayment: FlutterApplePayment?) -> (PKPaymentButtonType, PKPaymentButtonStyle)? {
        
        guard let params = flutterApplePayment,
              let style = params.pkPaymentButtonStyle,
              let type = params.pkPaymentButtonType else {
            return nil
        }
        
        return (type, style)
        
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
