//
// Created by Adnan Omerovic on 28. 10. 2021..
//

import Foundation
import Alamofire

@objc public class MonriHelper: NSObject {

    public func createPaymentSessionHelperFunc(_ callback: @escaping (NewPaymentResponse?) -> Void) {
        Alamofire.request("https://mobile.webteh.hr/example/create-payment-session",
                        method: .post,
//                          parameters: ["skip_authentication":"true"],
                        parameters: [:],
                        encoding: JSONEncoding.default)
                .responseJSON { dataResponse in
                    guard let data = dataResponse.data else {
                        callback(nil)
                        return
                    }
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                            callback(nil)
                            return
                        }
                        print(json)
                        guard let response = NewPaymentResponse.fromJson(json) else {
                            callback(nil)
                            return
                        }

                        callback(response)
                    } catch {
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
