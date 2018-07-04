//
//  PaymentsInteractor.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 26.06.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation

class PaymentsInteractor {
    
    func pay(parameters: ModuleParameters?,
             completion: @escaping (HTTPURLResponse?, ResponseError?) -> Void) {
        
        let service = MockPaymentsNetworkService()
        guard let parameters = parameters,
                let amount = parameters[PaymentsModuleParameters.suggestedAmount.rawValue] else {
                return
        }
        let token = parameters[PaymentsModuleParameters.token.rawValue]
        let payParameters = [PaymentsModuleParameters.token.rawValue: token ?? "",
                             PaymentsModuleParameters.suggestedAmount.rawValue: amount]
        
        service.post(host: "payments",
                     path: "/pay",
                     parameters: payParameters) { (response, urlResponse, error) in
                        
                        // We are not going to check errors and URL response status codes, just a shortest path.
                        var networkingError: ResponseError? = nil
                        if let error = error {
                            networkingError = ResponseError(error: error, response: urlResponse)
                        }
                        
                        completion(urlResponse, networkingError)
        }
    }
}

class MockPaymentsNetworkService: NetworkService {
    
    override func post(scheme: String? = nil,
                       host: String,
                       path: String,
                       parameters: [String : Any]?,
                       completion: @escaping ([String : Any]?, HTTPURLResponse?, Error?) -> Void) {
        
        // This is a mock service for a specific interactor, where we always expect parameters.
        guard let parameters = parameters else { return }
        
        // If we don't get a specific payment token, then we return 401
        if parameters[PaymentsModuleParameters.token.rawValue] as? String != "hf120938h12983dh" {
            
            let url = URL(schema: "https",
                          host: host,
                          path: path,
                          parameters: parameters as? [String : String])
            let response = HTTPURLResponse.init(url: url!,
                                                statusCode: 401,
                                                httpVersion: nil,
                                                headerFields: nil)
            let error = NSError.init(domain: "com.module.architecture.demo.network-errors",
                                     code: 401,
                                     userInfo: nil)
            
            print("Payment failed, 401")
            
            completion(nil, response, error)
        }
        else if parameters[PaymentsModuleParameters.suggestedAmount.rawValue] as? String != "" {
            
            let url = URL(schema: "https",
                          host: host,
                          path: path,
                          parameters: parameters as? [String : String])
            
            let urlResponse = HTTPURLResponse(url: url!,
                                              statusCode: 201,
                                              httpVersion: nil,
                                              headerFields: nil)
            
            print("Payment successful, 201")
            
            completion([String: String](), urlResponse, nil)
        }
        else {
            
            let error = NSError.init(domain: "com.module.architecture.demo.network-errors",
                                     code: 400,
                                     userInfo: nil)
            completion(nil, nil, error)
        }
    }
}
