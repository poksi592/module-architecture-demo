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

class PaymentModule: ModuleType, StoryboardModuleType {
    
    // We use the default storyboard, which can be changed later by injected parameter
    lazy var storyboard: UIStoryboard = UIStoryboard(name: "PaymentsStoryboard", bundle: nil)
    var presentationMode: ModulePresentationMode = .none
    
    var route: String = {
        return "payments"
    }()
    
    var paths: [String] = {
        return ["/pay",
                "/cancel-payment",
                "/refund"]
    }()
    
    var subscribedRoutables: [ModuleRoutable.Type] = [PaymentInteractor.self]

    func setup(parameters: ModuleParameters?) {
        
        if let storyboardName = parameters?[ModuleConstants.UrlParameter.storyboard] {
            storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        }
        
        setPresentationMode(from: parameters)
        present(viewController: initialViewController(from: parameters))
    }
}

class PaymentInteractor: ModuleRoutable {
    
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

