//
// Created by Adnan Omerovic on 28. 10. 2021..
//

import Foundation
import Alamofire
import CommonCrypto

@objc public class MonriHelper: NSObject {
    // Authentication variables
    private let key = "merchant-key" // Replace with your actual key
    private let authenticityToken = "authenticity-token" // Replace with your actual token
    
    public func createPaymentSessionHelperFunc(_ callback: @escaping (NewPaymentResponse?) -> Void) {
        // Required payment parameters
        let parameters: [String: Any] = [
            "amount": 100,
            "order_number": "order-\(Int(Date().timeIntervalSince1970))",
            "currency": "EUR",
            "transaction_type": "purchase",
            "order_info": "Create payment session order info",
            "scenario": "charge"
        ]
        
        // Create authorization header
        let timestamp = Int(Date().timeIntervalSince1970)
        
        // Convert parameters to JSON string
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters),
              let bodyAsString = String(data: jsonData, encoding: .utf8) else {
            callback(nil)
            return
        }
        
        // Create digest
        let digestInput = "\(key)\(timestamp)\(authenticityToken)\(bodyAsString)"
        let digest = digestInput.sha512()

        print("SHA512" + "da".sha512())
        
        // Create authorization header
        let authorization = "WP3-v2 \(authenticityToken) \(timestamp) \(digest)"
        
        // Set headers
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": authorization
        ]
        
        // Make request
        AF.request("https://ipgtest.monri.com/v2/payment/new",
                        method: .post,
                        parameters: parameters,
                        encoding: JSONEncoding.default,
                        headers: headers)
                .responseJSON { dataResponse in
                    guard let data = dataResponse.data else {
                        print("No data received")
                        callback(nil)
                        return
                    }
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                            print("Invalid JSON format")
                            callback(nil)
                            return
                        }
                        print(json)
                        guard let response = NewPaymentResponse.fromJson(json) else {
                            print("Could not parse response")
                            callback(nil)
                            return
                        }

                        callback(response)
                    } catch {
                        print("JSON parsing error: \(error)")
                        callback(nil)
                    }
                }
    }
}


public class NewPaymentResponse {
    public let clientSecret: String
    public let status: String

    public init(clientSecret: String, status: String) {
        self.clientSecret = clientSecret
        self.status = status
    }

    public static func fromJson(_ json: Dictionary<String, Any>) -> NewPaymentResponse? {
        return NewPaymentResponse(clientSecret: json["client_secret"] as! String, status: json["status"] as! String)
    }
}

// Extension to generate SHA-512 hash
extension String {
    func sha512() -> String {
        let data = Data(self.utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA512($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
