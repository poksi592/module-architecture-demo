//
//  Module.swift
//  TandemApp
//
//  Created by Mladen Despotovic on 12/05/2017.
//  Copyright © 2017 Mladen Despotovic. All rights reserved.
//

import Foundation
import UIKit

public typealias ModuleParameters = [String: String]

public struct ModuleConstants {
    
    struct UrlParameter {
        
        static let viewController = "viewController"
        static let presentationMode = "presentationMode"
        static let storyboard = "storyboard"
    }
}

public enum ResponseError: Error {
    
    case serializationFailed
    case taskCancelled
    case badRequest400(error: Error?)
    case unauthorized401(error: Error?)
    case forbidden403(error: Error?)
    case notFound404(error: Error?)
    case other400(error: Error?)
    case serverError500(error: Error?)
    case other
    
    init?(error: Error?, response: HTTPURLResponse?) {
        
        let responseCode: Int
        if let response = response {
            responseCode = response.statusCode
        } else {
            responseCode = 0
            self = .other
        }
        
        switch responseCode {
        case 200..<300:
            return nil
        case 400:
            self = .badRequest400(error: error)
        case 401:
            self = .unauthorized401(error: error)
        case 403:
            self = .forbidden403(error: error)
        case 404:
            self = .notFound404(error: error)
        case 405..<500:
            self = .other400(error: error)
        case 500..<600:
            self = .serverError500(error: error)
        default:
            self = .other
        }
    }
}

/**
 Application module represents a group off all the classes that implement a certain functionality of the module, like:
 
 - Storyboard
 - View Controllers
 - Views, specific to the module
 - Presenters, View Models and other Client architecture classes
 - ...
 
 Every module needs to identify itself with unique application route/domain which is queried by `ModuleHub`
 */
public protocol ModuleType {
    
    /**
     Every module needs to identify itself with a certain route/domain
     
     - returns:
     String that represents the route, domain, like _"/module-name"_
     */
    var route: String { get }
    
    /**
     Paths, which represent methods/functionalities a module has, module capabilities, actually
     
     - returns:
     Array of path strings
     */
    var paths: [String] { get }
    
    /**
     This array contains all the potential types module can let to route to.
     Reflection is used for memory savvy approach
     */
    var subscribedRoutables: [ModuleRoutable.Type] { get set }
    
    /**
     Function has to implement start of the module
     
     - parameters:
     - parameters: Simple dictionary of parameters
     - path: Path which is later recognised by specific module and converted to possible method
     */
    func open(parameters: ModuleParameters?,
              path: String?,
              callback: ModuleCallback?)
    
    /**
     This function could be called from `open` or any other for that matter.
     It facilitates any potentially additionally setup, that a module would eventually need.
     */
    func setup(parameters: ModuleParameters?)
}

public extension ModuleType {
    
    func open(parameters: ModuleParameters?, path: String?, callback: ModuleCallback?) {
        
        let subscribedRoutableType = subscribedRoutables.filter { subscribedType in
            
            let matchedType = subscribedType.getPaths().filter { $0 == path }
            if matchedType.isEmpty == false {
                return true
            }
            else {
                return false
            }
        }.first
        guard let subscribedRoutable = subscribedRoutableType else { return }
        subscribedRoutable.routable().route(parameters: parameters,
                                            path: path,
                                            callback: callback)
        
        setup(parameters: parameters)

    }
    
    func setup(parameters: ModuleParameters?) { }
}

/**
 Protocol should be adopted by the classes, which are routed directly by a `Module` and
 be registered in it.
 */
public protocol ModuleRoutable {

    /**
     Every class which wants to be routed by `Module` needs to identify itself with a certain path/method
     
     - returns:
     Collection of String that represents paths
     */
    static func getPaths() -> [String]
    
    /**
     Function which is a workaround for the weak reflection possibilites to
     create an instance of `ModuleRoutable` from `Class.Type`
     */
    static func routable() -> ModuleRoutable
    
    func route(parameters: ModuleParameters?,
               path: String?,
               callback: ModuleCallback?)
}

public class StoryboardIdentifiableViewController: UIViewController {
    
    var storyboardId: String? = nil
}







