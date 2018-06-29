//
//  PaymentsModule.swift
//  APIClientArchitectureDemo
//
//  Created by Mladen Despotovic on 26/03/2018.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation

enum PaymentsModuleParameters: String {
    
    case suggestedAmount
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
    
    var subscribedRoutables: [ModuleRoutable.Type] = [PaymentsPresenter.self]
}

