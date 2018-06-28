//
//  PaymentsInteractor.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 26.06.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation

class PaymentsInteractor: ModuleRoutable {
    
    static func routable() -> ModuleRoutable {
        return self.init()
    }
    
    static func getPaths() -> [String] {
        return ["/pay"]
    }
    
    func route(parameters: ModuleParameters?, path: String?, callback: ModuleCallback?) {
        
        pay(parameters: parameters)  { (urlResponse, error) in
            
            callback?(nil, nil, urlResponse, error)
        }
    }
    
    func pay(parameters: ModuleParameters?,
             completion: @escaping (HTTPURLResponse?, Error?) -> Void) {
        
        let service = MockPaymentsNetworkService()
        guard let parameters = parameters,
            let token = parameters[PaymentsModuleParameters.token.rawValue],
            let amount = parameters[PaymentsModuleParameters.suggestedAmount.rawValue] else {
                return
        }
        let payParameters = [PaymentsModuleParameters.token.rawValue: token,
                             PaymentsModuleParameters.suggestedAmount.rawValue: amount]
        
        service.post(host: "payments",
                     path: "/pay",
                     parameters: payParameters) { (response, urlResponse, error) in
                        
                        // We are not going to check errors and URL response status codes, just a shortest path.
                        var networkError: ResponseError? = nil
                        if let error = error {
                            networkError = ResponseError(error: error, response: urlResponse)
                        }
                        
                        completion(urlResponse, networkError)
        }
    }
}

class MockPaymentsNetworkService: NetworkService {
    
    override func post(scheme: String? = nil,
                       host: String,
                       path: String,
                       parameters: [String : Any]?,
                       completion: @escaping ([String : Any]?, HTTPURLResponse?, Error?) -> Void) {
        
        // Just some basic validation, nothing fancy
        if let parameters = parameters,
            parameters[PaymentsModuleParameters.token.rawValue] as? String == "hf120938h12983dh",
            parameters[PaymentsModuleParameters.suggestedAmount.rawValue] as? String != "" {
            
            let url = URL(schema: "https",
                          host: host,
                          path: path,
                          parameters: parameters as? [String : String])
            
            let urlResponse = HTTPURLResponse(url: url!,
                                              statusCode: 201,
                                              httpVersion: nil,
                                              headerFields: nil)
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
