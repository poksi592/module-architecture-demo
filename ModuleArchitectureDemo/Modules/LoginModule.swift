//
//  LoginModule.swift
//  APIClientArchitectureDemo
//
//  Created by Mladen Despotovic on 20/03/2018.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation

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
            
            interactor.getPaymentToken(parameters: parameters) { [weak self] (token, error) in
                
                guard let strongSelf = self,
                        let url = URL(schema: "tandem",
                                      host: strongSelf.route,
                                      path: path,
                                      parameters: parameters) else {
                    return
                }
                
                if let token = token {
                    
                    let urlResponse = HTTPURLResponse(url: url,
                                                      statusCode: 200,
                                                      httpVersion: nil,
                                                      headerFields: nil)
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
    
    func getPaymentToken(parameters: ModuleParameters?, completion: @escaping (String?, Error?) -> Void) {
        
        let service = NetworkService()
        guard let parameters = parameters,
                let username = parameters[LoginModuleParameters.username.rawValue],
                let password = parameters[LoginModuleParameters.password.rawValue] else {
                return
        }
        let getTokenParameters = [LoginModuleParameters.username.rawValue: username,
                                  LoginModuleParameters.password.rawValue: password]
        service.get(host: "login",
                    path: "/login",
                    parameters: getTokenParameters) { (response, data, urlResponse, error) in
            
            // We are not going to check errors and URL response status codes, just a shortest path.
            var networkError: ResponseError? = nil
            if let error = error {
                networkError = ResponseError(error: error, response: urlResponse)
            }
            
            let token = response?.filter { $0.key == "token"}.first?.value as? String
            
            completion(token, networkError)
        }
        
    }
    
    
//    func login(completion: @escaping (String?, Error?) -> Void) {
//
//        // Mocked login
//        completion("c24r47y23847byv8374bv", nil)
//
//    }
}

class MockLoginNetworkService: NetworkService {
    
    override func get(host: String,
                      path: String,
                      parameters: [String : Any]?,
                      completion: @escaping ([String : Any]?, Data?, HTTPURLResponse?, Error?) -> Void) {
        
        if let parameters = parameters,
            parameters[LoginModuleParameters.username.rawValue] as? String == "myUsername",
            parameters[LoginModuleParameters.password.rawValue] as? String == "myPassword" {
            
            
        }
    }
}
