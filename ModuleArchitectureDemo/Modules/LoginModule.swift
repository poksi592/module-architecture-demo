//
//  LoginModule.swift
//  APIClientArchitectureDemo
//
//  Created by Mladen Despotovic on 20/03/2018.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation

// A simple way of formalising request parameters within a module
enum LoginModuleParameters: String {
    
    case username
    case password
    case token
}

class LoginModule: ModuleType {
    
    var route: String = {
            return "login"
    }()
    
    var paths: [String] = {
        return ["/login",
                "/logout",
                "/payment-token"]
    }()
    
    lazy var moduleRouter = ModuleRouter.init(route: route)
    
    func open(parameters: ModuleParameters?, path: String?, callback: ModuleCallback?) {
        
        moduleRouter.route(parameters: parameters, path: path, callback: callback)
    }
}

class ModuleRouter {
    
    lazy var interactor = LoginInteractor()
    let route: String
    
    init(route: String) {
        
        self.route = route
    }
    
    func route(parameters: ModuleParameters?, path: String?, callback: ModuleCallback?) {
        
        switch path {
            
        case "/payment-token":
            
            interactor.getPaymentToken(parameters: parameters) { (token, urlResponse, error) in
                
                if let token = token {
                    
                    let responseData = try? JSONSerialization.data(withJSONObject: [LoginModuleParameters.token.rawValue: token],
                                                                   options: JSONSerialization.WritingOptions.prettyPrinted)
                    let response = [LoginModuleParameters.token.rawValue: token]
                    callback?(response, responseData, urlResponse, nil)
                }
                else {
                    
                    // Simplyfication of error response
                    callback?(nil, nil, nil, error)
                }
            }
            
        default:
            return
        }
    }
}

class LoginInteractor {
    
    func getPaymentToken(parameters: ModuleParameters?, completion: @escaping (String?, HTTPURLResponse?, Error?) -> Void) {
        
        let service = MockLoginNetworkService()
        guard let parameters = parameters,
                let username = parameters[LoginModuleParameters.username.rawValue],
                let password = parameters[LoginModuleParameters.password.rawValue] else {
                return
        }
        let getTokenParameters = [LoginModuleParameters.username.rawValue: username,
                                  LoginModuleParameters.password.rawValue: password]
        service.get(host: "login",
                    path: "/login",
                    parameters: getTokenParameters) { (response, urlResponse, error) in
            
            // We are not going to check errors and URL response status codes, just a shortest path.
            var networkError: ResponseError? = nil
            if let error = error {
                networkError = ResponseError(error: error, response: urlResponse)
            }
            
            let token = response?.filter { $0.key == "token"}.first?.value as? String
            
            completion(token, urlResponse, networkError)
        }
        
    }
}

class MockLoginNetworkService: NetworkService {
    
    override func get(host: String,
                      path: String,
                      parameters: [String : Any]?,
                      completion: @escaping ([String : Any]?, HTTPURLResponse?, Error?) -> Void) {
        
        if let parameters = parameters,
            parameters[LoginModuleParameters.username.rawValue] as? String == "myUsername",
            parameters[LoginModuleParameters.password.rawValue] as? String == "myPassword" {
            
            let url = URL(schema: "https",
                          host: host,
                          path: path,
                          parameters: parameters as? [String : String])

            let urlResponse = HTTPURLResponse(url: url!,
                                              statusCode: 200,
                                              httpVersion: nil,
                                              headerFields: nil)
            completion([LoginModuleParameters.token.rawValue: "hf120938h12983dh"], urlResponse, nil)
        }
        else {
            
            let error = NSError.init(domain: "com.module.architecture.demo.network-errors",
                                     code: 403,
                                     userInfo: nil)
            completion(nil, nil, error)
        }
    }
}




