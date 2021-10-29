//
//  FlutterConfirmPaymentParams.swift
//  MonriPayments
//
//  Created by Jasmin Suljic on 18/11/2020.
//

import Foundation
import Monri
//
//  FlutterConfirmPaymentParams.swift
//  MonriPayments
//
//  Created by Jasmin Suljic on 18/11/2020.
//

import Foundation

class FlutterConfirmPaymentParams {
    let developmentMode: Bool
    let authenticityToken: String
    let clientSecret: String
    let card: FlutterCard?
    let savedCard: FlutterSavedCard?
    let transactionParams: FlutterTransactionParams
    
    init(_ developmentMode: Bool,_ authenticityToken: String,_ clientSecret: String,_ card: FlutterCard?,_ savedCard: FlutterSavedCard?,_ transactionParams: FlutterTransactionParams) {
        self.developmentMode = developmentMode
        self.authenticityToken = authenticityToken
        self.clientSecret = clientSecret
        self.card = card
        self.savedCard = savedCard
        self.transactionParams = transactionParams
    }
    
    func monriApiOptions() ->MonriApiOptions {
        return MonriApiOptions(authenticityToken: authenticityToken, developmentMode: developmentMode)
    }
    
    private static func card(cardMap: Dictionary<String, AnyObject?>) -> FlutterCard {
        let number: String = cardMap["pan"] as! String
        let cvv: String = cardMap["cvv"] as! String
        let tokenizePan: Bool = cardMap["tokenize_pan"] as! Bool
        let expYear: Int = cardMap["expiry_year"] as! Int
        let expMonth: Int = cardMap["expiry_month"] as! Int
        return FlutterCard(number, cvv, expYear, expMonth, tokenizePan)
    }
    
    private func paymentMethodParams() -> PaymentMethodParams {
        if let card = card {
            return Card(number: card.pan, cvc: card.cvv, expMonth: card.month, expYear: card.year, tokenizePan: card.tokenizePan).toPaymentMethodParams()
        }
        
        return SavedCard(panToken: savedCard!.panToken, cvc: savedCard!.cvv).toPaymentMethodParams()
    }
    
    private func buildMonriTransactionParams() -> TransactionParams {
        let customerParams: CustomerParams = CustomerParams(email: transactionParams.email,
                                                            fullName: transactionParams.fullName,
                                                            address: transactionParams.address,
                                                            city: transactionParams.city,
                                                            zip: transactionParams.zip,
                                                            phone: transactionParams.phone,
                                                            country: transactionParams.country
        )
        
        return TransactionParams.create()
            .set(customerParams:customerParams)
            .set("custom_params", transactionParams.customParams)
    }
    
    
    private static  func savedCard(cardMap: Dictionary<String, AnyObject?>) -> FlutterSavedCard {
        return FlutterSavedCard(
            cardMap["pan_token"] as! String,
            cardMap["cvv"] as! String
        )
    }
    
    func confirmPaymentParams() -> ConfirmPaymentParams {
        return ConfirmPaymentParams(paymentId: clientSecret, paymentMethod: paymentMethodParams(), transaction: buildMonriTransactionParams())
    }
    
    static func create(request: Dictionary<String, AnyObject?>, card: FlutterCard?, savedCard: FlutterSavedCard?) -> FlutterConfirmPaymentParams {
        let authenticityToken: String = request["authenticity_token"] as! String
        let clientSecret: String = request["client_secret"] as! String
        let developmentMode: Bool = request["is_development_mode"] as! Bool
        let transactionParamsJSON: Dictionary<String, AnyObject?> = request["transaction_params"] as! Dictionary<String, AnyObject?>
        
        let transactionParams: FlutterTransactionParams  = FlutterTransactionParams(
            orderInfo: transactionParamsJSON["order_info"] as? String,
            email: transactionParamsJSON["email"] as? String,
            fullName: transactionParamsJSON["full_name"] as? String,
            address: transactionParamsJSON["address"] as? String,
            city: transactionParamsJSON["city"] as? String,
            zip: transactionParamsJSON["zip"] as? String,
            phone: transactionParamsJSON["phone"] as? String,
            country: transactionParamsJSON["country"] as? String,
            customParams:transactionParamsJSON["custom_params"] as? String
        )
        
        return FlutterConfirmPaymentParams(developmentMode, authenticityToken, clientSecret, card, savedCard, transactionParams)
    }
    
    static func forCard(request: Dictionary<String, AnyObject?>) -> FlutterConfirmPaymentParams {
        return Self.create(request: request,
                           card: Self.card(cardMap: request["card"] as! Dictionary<String, AnyObject?>),
                           savedCard: nil
        )
    }
    
    static func forSavedCard(request: Dictionary<String, AnyObject?>) -> FlutterConfirmPaymentParams {
        return Self.create(request: request,
                           card: nil,
                           savedCard: Self.savedCard(cardMap: request["saved_card"] as! Dictionary<String, AnyObject?>)
        )
    }
}

class FlutterCard {
    let pan: String
    let cvv: String
    let year: Int
    let month: Int
    let tokenizePan: Bool
    
    init(_ pan: String,_ cvv: String,_ year: Int,_ month: Int,_ tokenizePan: Bool) {
        self.pan = pan
        self.cvv = cvv
        self.year = year
        self.month = month
        self.tokenizePan = tokenizePan
    }
}

class FlutterSavedCard {
    let panToken: String
    let cvv: String
    init(_ panToken: String, _ cvv:String) {
        self.panToken = panToken
        self.cvv = cvv
    }
}

class FlutterTransactionParams {
    let orderInfo: String?
    let email: String?
    let fullName: String?
    let address: String?
    let city: String?
    let zip: String?
    let phone: String?
    let country: String?
    let customParams: String?
    
    init(orderInfo: String?,
         email: String?,
         fullName: String?,
         address: String?,
         city: String?,
         zip: String?,
         phone: String?,
         country: String?,
         customParams: String?
    ) {
        self.orderInfo = orderInfo
        self.email = email
        self.fullName = fullName
        self.address = address
        self.city = city
        self.zip = zip
        self.phone = phone
        self.country = country
        self.customParams = customParams
    }
}

