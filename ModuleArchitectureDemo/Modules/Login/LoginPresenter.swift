//
//  LoginPresenter.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 29.06.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation

class LoginPresenter: ModuleRoutable {
    
    lazy private var wireframe: WireframeType = PaymentWireframe()
    lazy private var interactor = LoginInteractor()
    
    static func routable() -> ModuleRoutable {
        return self.init()
    }
    
    static func getPaths() -> [String] {
        return ["/payment-token",
                "/login"]
    }
    
    func route(parameters: ModuleParameters?, path: String?, callback: ModuleCallback?) {
        
        wireframe.setupWireframe(parameters: parameters)
    }
}
