//
//  PaymentsModule.swift
//  APIClientArchitectureDemo
//
//  Created by Mladen Despotovic on 26/03/2018.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation
import UIKit

class PaymentModule: ModuleType {
    
    var route: String = {
        return "payments"
    }()
    
    var paths: [String] = {
        return ["/pay",
                "/cancel-payment",
                "/refund"]
    }()
    
    lazy var interactor = PaymentInteractor()
    
    func open(parameters: ModuleParameters?, path: String?, callback: ModuleCallback?) {
        
        if path == "/pay" {
            
            // We won't make any efforts to make this part of architecture any better. For now.
            // Let's assume each time we want to perform a payment, we need to get a token for it.
            interactor.getPaymentToken { (token, error) in
                
                if let token = token {
                    
                    let alert = UIAlertController(title: "Success",
                                                  message: "Your payment with the token \(token) was successful without us even making one",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .`default`))
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

class PaymentInteractor {
    
    func getPaymentToken(completion: @escaping (String?, Error?) -> Void) {
        
        let service = NetworkService()
        let parameters = ["username": "myUsername",
                          "password": "password123"]
        service.get(host: "login", path: "/login", parameters: parameters) { (response, data, urlResponse, error) in
            
            // We are not going to check errors and URL response status codes, just a shortest path.
            var networkError: ResponseError? = nil
            if let error = error {
                networkError = ResponseError(error: error, response: urlResponse)
            }
            
            let token = response?.filter { $0.key == "token"}.first?.value as? String

            completion(token, networkError)
        }
        
    }
}

