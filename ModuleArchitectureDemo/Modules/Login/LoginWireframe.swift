//
//  LoginWireframe.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 29.06.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation
import UIKit

class LoginWireframe: WireframeType {
    
    // We use the default storyboard, which can be changed later by injected parameter
    lazy var storyboard: UIStoryboard = UIStoryboard(name: "LoginStoryboard", bundle: nil)
    lazy var presentedViewControllers = [WeakContainer<UIViewController>]()
    var presentationMode: ModulePresentationMode = .none
    
    func presentLoginViewController(with presenter: LoginPresenter, parameters: ModuleParameters?) {
        
        setPresentationMode(from: parameters)
        if let viewController = viewController(from: parameters) {
            
            present(viewController: viewController)
            guard let loginViewController = viewController as? LoginViewController else { return }
            loginViewController.presenter = presenter
        }
    }
}
