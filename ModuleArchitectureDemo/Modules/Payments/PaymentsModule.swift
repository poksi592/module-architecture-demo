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

class PaymentWireframe: WireframeType {

    // We use the default storyboard, which can be changed later by injected parameter
    lazy var storyboard: UIStoryboard = UIStoryboard(name: "PaymentsStoryboard", bundle: nil)
    lazy var presentedViewControllers = [WeakContainer<UIViewController>]()
    var presentationMode: ModulePresentationMode = .none
    
    func presentPayViewController(with presenter: PaymentsPresenter, parameters: ModuleParameters?) {
        
        setPresentationMode(from: parameters)
        if let viewController = viewController(from: parameters) {
            present(viewController: viewController)
        }
    }
}

