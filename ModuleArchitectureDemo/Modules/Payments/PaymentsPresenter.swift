//
//  PaymentsPresenter.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 28.06.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation

class PaymentsPresenter: ModuleRoutable {
    
    lazy private var wireframe = PaymentWireframe()
    lazy private var interactor = PaymentsInteractor()
    private var parameters: ModuleParameters?
    private var callback: ModuleCallback?
    
    static func routable() -> ModuleRoutable {
        return self.init()
    }
    
    static func getPaths() -> [String] {
        return ["/pay"]
    }
    
    func route(parameters: ModuleParameters?, path: String?, callback: ModuleCallback?) {
        
        self.parameters = parameters
        self.callback = callback
        wireframe.presentPayViewController(with: self, parameters: parameters)
    }
    
    func pay(amount: String?) {
        
        if let amount = amount {
            parameters?[PaymentsModuleParameters.suggestedAmount.rawValue] = amount
            interactor.pay(parameters: parameters) { [weak self] (response, error) in
                
                self?.callback?(nil, nil, response, error)
            }
        }
    }
}
