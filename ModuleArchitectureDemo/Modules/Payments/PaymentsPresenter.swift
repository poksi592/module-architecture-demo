//
//  PaymentsPresenter.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 28.06.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation

class PaymentsPresenter: ModuleRoutable {
    
    lazy var wireframe: WireframeType = PaymentWireframe()
    
    static func routable() -> ModuleRoutable {
        return self.init()
    }
    
    static func getPaths() -> [String] {
        return ["/pay"]
    }
    
    func route(parameters: ModuleParameters?, path: String?, callback: ModuleCallback?) {
        
        wireframe.setupWireframe(parameters: parameters)
    }
}
