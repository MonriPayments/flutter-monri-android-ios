import Flutter
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
    
    var monri: MonriApi!;
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch(call.method){
        case "confirmPayment" : confirmPayment(call.arguments, result);
        default : result(FlutterMethodNotImplemented);
        }
    }
    
    private func buildFlutterConfirmPaymentParams(_ arguments: Any?) throws -> FlutterConfirmPaymentParams  {
        let request = arguments as! Dictionary<String, AnyObject?>
        
        print(request)
        
        if let _ = request["card"] {
            return FlutterConfirmPaymentParams.forCard(request: request)
        }
        
        if let _ = request["saved_card"] {
            return FlutterConfirmPaymentParams.forSavedCard(request: request)
        }
        
        throw ConfigurationError.unsupportedPaymentMethod
    }
    
    func confirmPayment(_ arguments: Any?, _ result: @escaping FlutterResult) {
        print("🔵 iOS: Starting confirmPayment")
        do {
            let params = try buildFlutterConfirmPaymentParams(arguments)
            print("🔵 iOS: Payment mode: development=\(params.developmentMode)")
            
            // Log tokenization request if present
            if let card = params.card {
                print("🔵 iOS: Card payment with tokenize_pan=\(card.tokenizePan)")
                // Safely log masked PAN (first 6 + last 4 digits)
                let maskedPan = maskPan(card.pan)
                print("🔵 iOS: Card details: PAN=\(maskedPan), expMonth=\(card.month), expYear=\(card.year)")
            } else if let savedCard = params.savedCard {
                print("🔵 iOS: Using saved card with token")
            }
            
            let confirmPaymentParams = params.confirmPaymentParams()
            let monriOptions = params.monriApiOptions()
            
            writeMetaData()
            
            self.monri = MonriApi(rootViewController, options: monriOptions);
            
            monri.confirmPayment(confirmPaymentParams, { [result] confirmPayment in
                switch confirmPayment {
                case .result(let paymentResult):
                    print("🔵 iOS: Payment successful: \(paymentResult.status)")
                    result(["status" : "result", "data" : paymentResult.toJSON()]);
                case .declined(let confirmPaymentDeclined):
                    print("🔵 iOS: Payment declined: \(confirmPaymentDeclined.status)")
                    print("🔵 iOS: Decline reason: \(confirmPaymentDeclined.clientSecret ?? "none")")
                    result(["status" : "declined", "data" : confirmPaymentDeclined.status]);
                case .error(let error):
                    print("🔵 iOS: Payment error: \(error.localizedDescription)")
                    if let nsError = error as NSError? {
                        print("🔵 iOS: Error details: code=\(nsError.code), domain=\(nsError.domain)")
                        print("🔵 iOS: User info: \(nsError.userInfo)")
                    }
                    result(["status" : "error", "data": ["error": error.localizedDescription]]);
                case .pending:
                    print("🔵 iOS: Payment pending")
                    result(["status" : "pending"]);
                }
            });
        } catch let error as ConfigurationError {
            print("🔵 iOS: Configuration error: \(error)")
            result(["error" : "Unsupported payment method, 'card' or 'saved_card' not found", "status": "error"]);
        } catch let error {
            print("🔵 iOS: General error: \(error)")
            result(["error" : "An error occurred on confirmPayment - \(error)", "status": "error"]);
        }
    }

    private func writeMetaData(){
        let version: String = Bundle(identifier: "org.cocoapods.MonriPayments")?.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"

        let defaults = UserDefaults.standard
        defaults.set("iOS-SDK:Flutter:\(version)", forKey: "com.monri.meta.library")
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
