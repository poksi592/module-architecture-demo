//
//  PaymentsModule.swift
//  APIClientArchitectureDemo
//
//  Created by Mladen Despotovic on 26/03/2018.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation
import UIKit

enum PaymentsModuleParameters: String {
    
    case amount
    case token
}

class PaymentModule: ModuleType {
    
    var route: String = {
        return "payments"
    }()
    
    var paths: [String] = {
        return ["/pay",
                "/cancel-payment",
                "/refund"]
    }()
    
    lazy var moduleRouter = PaymentsModuleRouter(route: route)
    
    func open(parameters: ModuleParameters?, path: String?, callback: ModuleCallback?) {
        
        moduleRouter.route(parameters: parameters, path: path, callback: callback)
    }
}

class PaymentsModuleRouter: ModuleRouter {
    
    lazy var interactor = PaymentInteractor()
    internal var route: String
    
    required init(route: String) {
        
        self.route = route
    }
    
    func route(parameters: ModuleParameters?,
               path: String?,
               callback: ModuleCallback?) {
        
        switch path {
        case "/pay":
            
            interactor.pay(parameters: parameters) { (urlResponse, error) in
                
                callback?(nil, nil, urlResponse, error)
            }
            
        default:
            return
        }
    }
}

class PaymentInteractor {
    
    func pay(parameters: ModuleParameters?,
             completion: @escaping (HTTPURLResponse?, Error?) -> Void) {
        
        let service = MockPaymentsNetworkService()
        guard let parameters = parameters,
            let token = parameters[PaymentsModuleParameters.token.rawValue],
            let amount = parameters[PaymentsModuleParameters.amount.rawValue] else {
                return
        }
        let payParameters = [PaymentsModuleParameters.token.rawValue: token,
                             PaymentsModuleParameters.amount.rawValue: amount]

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
            parameters[PaymentsModuleParameters.amount.rawValue] as? String != "" {
            
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

