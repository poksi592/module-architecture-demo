//
//  LoginPresenter.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 29.06.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation

class LoginPresenter: ModuleRoutable {
    
    lazy private var wireframe = LoginWireframe()
    lazy private var interactor = LoginInteractor()
    private var parameters: ModuleParameters?
    private var callback: ModuleCallback?
    
    static func routable() -> ModuleRoutable {
        return self.init()
    }
    
    static func getPaths() -> [String] {
        return ["/payment-token",
                "/login"]
    }
    
    func route(parameters: ModuleParameters?, path: String?, callback: ModuleCallback?) {
        
        self.parameters = parameters
        self.callback = callback
        wireframe.presentLoginViewController(with: self, parameters: parameters)
    }
    
    func login(username: String?, password: String?) {
        
        guard let username = username,
            let password = password else { return }
        
        parameters?[LoginModuleParameters.username.rawValue] = username
        parameters?[LoginModuleParameters.password.rawValue] = password
        interactor.getPaymentToken(parameters: parameters) { [weak self] (token, urlResponse, error) in
            
            let response = [LoginModuleParameters.paymentToken.rawValue: token]
            self?.callback?(response, nil, urlResponse, error)
        }
    }
    
}
