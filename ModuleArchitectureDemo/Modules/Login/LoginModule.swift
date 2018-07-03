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
    case paymentToken
    case bearerToken
}

class LoginModule: ModuleType {
    
    func setup(parameters: ModuleParameters?) {}

    var route: String = {
            return "login"
    }()
    
    var paths: [String] = {
        return ["/login",
                "/logout",
                "/payment-token"]
    }()
    
    var subscribedRoutables: [ModuleRoutable.Type] = [LoginPresenter.self]
    var instantiatedRoutables: [WeakContainer<ModuleRoutable>] = []
}






