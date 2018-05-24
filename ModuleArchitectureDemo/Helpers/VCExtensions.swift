//
//  VCExtensions.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 22/05/2018.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    class func topPresentedController() -> UIViewController? {
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        guard let rootViewController = delegate?.window?.rootViewController else {
            return nil
        }

        var topViewController = rootViewController
        while let presentedViewController = topViewController.presentedViewController{
            topViewController = presentedViewController
        }
        return rootViewController
    }
    
    func topPresentedController() -> UIViewController? {
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        guard let rootViewController = delegate?.window?.rootViewController else {
            return nil
        }
        
        var topViewController = rootViewController
        while let presentedViewController = topViewController.presentedViewController{
            topViewController = presentedViewController
        }
        return self
    }
    
    /**
     Simplified function to get the topmost UINavigationController.
     This can be written in many ways and can reflect the actual app navigation specifics.
     */
    func topmostNavigationController() -> UINavigationController? {
        
        var topRootViewController = self
        while let presentedViewController = topRootViewController.presentedViewController{
            topRootViewController = presentedViewController
        }
        
        switch topRootViewController {
        case let navigationViewController as UINavigationController:
            return navigationViewController
        case let tabBarViewController as UITabBarController:
            return tabBarViewController.selectedViewController as? UINavigationController
        default:
            return nil
        }
    }
}

