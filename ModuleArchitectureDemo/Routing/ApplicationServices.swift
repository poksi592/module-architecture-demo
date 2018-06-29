//
//  ApplicationServices.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 28.06.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation


class ApplicationServices {
    
    // ApplicationServices is a singleton, because it makes it easier to be accessed from anywhere to access its functions/services
    static let shared = ApplicationServices()
    let appRouter = ApplicationRouter()
    
    func pay(amount: Double,
             paymentToken: String?,
             completion: @escaping (() -> Void)) {
        
        // MARK Urls to make the logic more readable, not to clog the logic in closures in the service
        func payUrl(amount: Double, paymentToken: String?) -> URL? {
            
            guard let moduleUrl = URL(schema: "tandem",
                                      host: "payments",
                                      path: "/pay",
                                      parameters: ["amount": String(amount),
                                                   "token": paymentToken ?? "",
                                                   "presentationMode": "navigationStack",
                                                   "viewController": "PaymentsViewControllerId"]) else { return nil }
            return moduleUrl
        }
        
        func loginUrl() -> URL? {

            guard let moduleUrl = URL(schema: "tandem",
                                      host: "login",
                                      path: "/paymentToken",
                                      parameters: nil) else { return nil }
            return moduleUrl
        }

        // MARK Logic - Start
        // Summary: If PaymentsModule fails because of missing or expired or faulty `paymentToken`,
        // then LoginModule is called and `paymentToken` by using its login window and user putting
        // username and password in.
        // All logic and orchestration between these 2 modules is contained in the code below and both
        // modules do not know anything about each other
        guard let paymentUrl = payUrl(amount: amount, paymentToken: paymentToken),
                let loginUrl = loginUrl() else { return }
        
        appRouter.open(url: paymentUrl) { [weak self] (response, responseData, urlResponse, error) in
            
            if case .unauthorized401(_)? = error {
                
                self?.appRouter.open(url: loginUrl) { (response, responseData, urlResponse, error) in
                    
                    if let response = response,
                        let paymentToken = response["paymentToken"] as? String {
                        
                        self?.pay(amount: amount, paymentToken: paymentToken, completion: {
                            completion()
                        })
                    } else {
                        completion()
                    }
                }
            }
            completion()
        }
        // MARK Logic - End
    }
}
