//
//  PaymentsWireframe.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 29.06.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation
import UIKit

class PaymentWireframe: WireframeType {
    
    // We use the default storyboard, which can be changed later by injected parameter
    lazy var storyboard: UIStoryboard = UIStoryboard(name: "PaymentsStoryboard", bundle: nil)
    var presentedViewControllers = [WeakContainer<UIViewController>]()
    var presentationMode: ModulePresentationMode = .none
    
    func presentPayViewController(with presenter: PaymentsPresenter, parameters: ModuleParameters?) {
        
        setPresentationMode(from: parameters)
        if let viewController = viewController(from: parameters) {
            
            present(viewController: viewController)
            guard let paymentsViewController = viewController as? PaymentsViewController else { return }
            paymentsViewController.presenter = presenter
        }
    }
}
