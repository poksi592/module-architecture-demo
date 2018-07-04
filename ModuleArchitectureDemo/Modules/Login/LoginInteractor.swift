//
//  LoginInteractor.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 29.06.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation

class LoginInteractor: ModuleRoutable {
    
    static func routable() -> ModuleRoutable {
        return self.init()
    }
    
    static func getPaths() -> [String] {
        return ["/payment-token",
                "/login"]
    }
    
    func route(parameters: ModuleParameters?,
               path: String?,
               callback: ModuleCallback?) {
        
        switch path {
            
        case "/payment-token":
            
            getPaymentToken(parameters: parameters) { (token, urlResponse, error) in
                
                if let token = token {
                    
                    let response = [LoginModuleParameters.paymentToken.rawValue: token]
                    callback?(response,  nil, urlResponse, nil)
                }
                else {
                    
                    // Simplyfication of error response
                    callback?(nil, nil, nil, ResponseError(error: error, response: urlResponse))
                }
            }
            
        case "/login":
            
            login(parameters: parameters) { (token, urlResponse, error) in
                
                if let token = token {
                    
                    let response = [LoginModuleParameters.bearerToken.rawValue: token]
                    callback?(response, nil, urlResponse, nil)
                }
                else {
                    
                    // Simplyfication of error response
                    callback?(nil, nil, nil, ResponseError(error: error, response: urlResponse))
                }
            }
            
        default:
            return
        }
        
    }
    
    func getPaymentToken(parameters: ModuleParameters?,
                         completion: @escaping (String?, HTTPURLResponse?, ResponseError?) -> Void) {
        
        let service = MockLoginNetworkService()
        
        // If parameters are not passed, then we exit with Bad Request at once
        guard let parameters = parameters,
            let username = parameters[LoginModuleParameters.username.rawValue],
            let password = parameters[LoginModuleParameters.password.rawValue] else {
                
                let url = URL.init(schema: "tandem", host: "login")
                let response = HTTPURLResponse.init(url: url!,
                                                    statusCode: 400,
                                                    httpVersion: nil,
                                                    headerFields: nil)
                completion(nil, response, nil)
                return
        }
        let getTokenParameters = [LoginModuleParameters.username.rawValue: username,
                                  LoginModuleParameters.password.rawValue: password]
        service.post(host: "login",
                     path: "/payment-token",
                     parameters: getTokenParameters) { (response, urlResponse, error) in
                        
                        // We are not going to check errors and URL response status codes, just a shortest path.
                        var networkError: ResponseError? = nil
                        if let error = error {
                            networkError = ResponseError(error: error, response: urlResponse)
                        }
                        let token = response?["paymentToken"] as? String
                        
                        completion(token, urlResponse, networkError)
        }
    }
    
    func login(parameters: ModuleParameters?,
               completion: @escaping (String?, HTTPURLResponse?, ResponseError?) -> Void) {
        
        let service = MockLoginNetworkService()
        guard let parameters = parameters,
            let username = parameters[LoginModuleParameters.username.rawValue],
            let password = parameters[LoginModuleParameters.password.rawValue] else {
                return
        }
        let loginParameters = [LoginModuleParameters.username.rawValue: username,
                               LoginModuleParameters.password.rawValue: password]
        service.post(host: "login",
                     path: "/login",
                     parameters: loginParameters) { (response, urlResponse, error) in
                        
                        // We are not going to check errors and URL response status codes, just a shortest path.
                        var networkError: ResponseError? = nil
                        if let error = error {
                            networkError = ResponseError(error: error, response: urlResponse)
                        }
                        let token = response?["bearerToken"] as? String
                        
                        completion(token, urlResponse, networkError)
        }
    }
}

class MockLoginNetworkService: NetworkService {
    
    override func post(scheme: String? = nil,
                       host: String,
                       path: String,
                       parameters: [String : Any]?,
                       completion: @escaping ([String : Any]?, HTTPURLResponse?, Error?) -> Void) {
        
        switch path {
        case "/payment-token":
            
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
                
                print("Login for payment token successful, 200")
                
                completion([LoginModuleParameters.paymentToken.rawValue: "hf120938h12983dh"], urlResponse, nil)
            }
            else {
                
                let error = NSError.init(domain: "com.module.architecture.demo.network-errors",
                                         code: 401,
                                         userInfo: nil)
                
                print("Login for payment token failed, 400")
                
                completion(nil, nil, error)
            }
            
        case "/login":
            
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
                completion([LoginModuleParameters.bearerToken.rawValue: "AbCdEf123456"], urlResponse, nil)
            }
            else {
                
                let error = NSError.init(domain: "com.module.architecture.demo.network-errors",
                                         code: 401,
                                         userInfo: nil)
                completion(nil, nil, error)
            }
            
        default:
            
            let error = NSError.init(domain: "com.module.architecture.demo.network-errors",
                                     code: 404,
                                     userInfo: nil)
            completion(nil, nil, error)
        }
    }
}
