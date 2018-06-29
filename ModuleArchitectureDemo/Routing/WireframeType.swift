//
//  StoryboardModule.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 19/05/2018.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation
import UIKit

public enum ModulePresentationMode: String {
    
    case none
    case root
    case navigationStack
    case modal
}

/**
 This protocol will contain functionality that is used primarily by modules that origin from Storyboard
 */
public protocol WireframeType: class {
    
    var storyboard: UIStoryboard { get set }
    var presentationMode: ModulePresentationMode { get set }
    var presentedViewControllers: [WeakContainer<UIViewController>] { get set }
    
    /**
     Returns `initialViewController`, if its name is specified in parameters, where key by convention is equal to `viewController`
     
     - parameters: Dictionary that contains key-value pairs of different parameters from URL.
     If it contains the key `viewController` then its value is used as name of view controller
     - returns: UIViewController, which is default from storyboard of the one that was specified by parameters
     */
    func initialViewController(from parameters:[String: String]?) -> UIViewController?
    
    /**
     Sets `presentationMode`, if its name is specified in parameters, where key by convention is equal to `presentationMode`
     
     - parameters: Dictionary that contains key-value pairs of different parameters from URL.
     If it contains the key `presentationMode` then its value is used to init view controller
     If it's `nil`, then `.root` is assumed.
     */
    func setPresentationMode(from parameters:[String: String]?)
    
    /**
     Presents view controller according to `presentationMode`
     
     - parameters:
     - viewController: UIViewController to be presented
     - navigationViewController: if `presentationMode` is equal to `navigationStack`, then this value will be used to get
     */
    func present(viewController: UIViewController)
    
    /**
     Function with generic set of parameters. Should be called from `StoryboardModuleType`.
     */
    func setupWireframe(parameters: ModuleParameters?)
}


extension WireframeType {
    
    func setupWireframe(parameters: ModuleParameters?) {
        
        // Guard prevents from initial VC being added again each time `open` function is
        // run from the Module
        // Each time it's called, `presentedViewControllers` is cleared from empty containers
        presentedViewControllers = presentedViewControllers.filter { $0.value != nil }
        guard presentedViewControllers.isEmpty else { return }
        
        if let storyboardName = parameters?[ModuleConstants.UrlParameter.storyboard] {
            storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        }
        
        setPresentationMode(from: parameters)
        if let viewController = initialViewController(from: parameters) {
            present(viewController: viewController)
            presentedViewControllers.append(WeakContainer(value: viewController))
        }
    }
    
    func viewController(from parameters:[String: String]?) -> UIViewController? {
        
        guard let viewControllerName = parameters?[ModuleConstants.UrlParameter.viewController] else {
            return nil
        }
        let viewController = storyboard.instantiateViewController(withIdentifier: viewControllerName)
        
        // If VC doesn't inherit from to `StoryboardIdentifiable`, then we assume caller will
        // use it on his own discretion, so we return it.
        guard let identifiableVc = viewController as? StoryboardIdentifiableViewController else {
            return viewController
        }
        
        // One particular view controller should be presented only once if
        // it conforms to the StoryboardIdentifiable protocol
        // Here we add it to the array of already presented
        let identifier = parameters?[ModuleConstants.UrlParameter.viewController]
        
        // Each time it's called, `presentedViewControllers` is cleared from empty containers
        presentedViewControllers = presentedViewControllers.filter { $0.value != nil }
        let instantiatedVc = presentedViewControllers.filter { wrappedVc in
            
            let storyboardId = wrappedVc.value as? StoryboardIdentifiableViewController
            return storyboardId?.storyboardId == identifier ? true : false
        }
        
        if instantiatedVc.isEmpty == true {
            
            identifiableVc.storyboardId = identifier
            presentedViewControllers.append(WeakContainer(value: identifiableVc))
            return identifiableVc
        }
        else {
            return nil
        }
    }

    /**
     This function could be private, too, but we assume module might want to inject some other
     properties to it, therefore we hand over control to the module, after initial VC is instantiated
     */
    func initialViewController(from parameters:[String: String]?) -> UIViewController? {
        
        guard let viewControllerName = parameters?[ModuleConstants.UrlParameter.viewController] else {
            
            return storyboard.instantiateInitialViewController()
        }
        return storyboard.instantiateViewController(withIdentifier: viewControllerName)
    }
    

    func setPresentationMode(from parameters: [String: String]?) {
        
        guard let mode = parameters?[ModuleConstants.UrlParameter.presentationMode],
                let modulePresentationMode = ModulePresentationMode(rawValue: mode) else {
                
                presentationMode = .root
                return
        }
        presentationMode = modulePresentationMode
    }
    
    
    func present(viewController: UIViewController) {
        
        DispatchQueue.main.async {
            
            switch self.presentationMode {
                
            case .navigationStack:
                
                guard let navController = UIViewController.topPresentedController()?.topmostNavigationController() else {
                    
                    assertionFailure("ModuleHub: attempt to push controller on the top navigation controller failed - no UINavigationController found")
                    return
                }
                
                navController.pushViewController(viewController, animated: true)
                
            case .modal:
                
                guard let delegate = UIApplication.shared.delegate as? AppDelegate,
                        let window = delegate.window,
                        let rootViewController = window.rootViewController else { return }
                
                let currentVc = rootViewController.topmostNavigationController()?.childViewControllers.last?.topPresentedController() ?? rootViewController.topPresentedController()
                
                // If we want to use modal with navigation bar, we can simply set it up in storyboard.
                // We could do this here as well, if we'd have some other app global navigation scenarios.
                
                currentVc?.present(viewController, animated: true, completion: nil)
                
            case .none: ()
                
            case .root:
                
                 // Default is .root
                fallthrough
                
            default:
                
                let delegate = UIApplication.shared.delegate as? AppDelegate
                delegate?.window?.rootViewController = viewController
                delegate?.window?.makeKeyAndVisible()
            }
        }
    }
}
