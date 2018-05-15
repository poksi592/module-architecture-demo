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

struct ModuleConstants {
    
    struct UrlParameter {
        
        static let viewController = "viewController"
        static let selectedTab = "tabIndex"
        static let path = "path"
        static let presentationMode = "presentationMode"
    }
}

enum ResponseError: Error {
    
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
protocol ModuleType {
    
    /**
     Every module needs to identify itself with a certain route/domain
     
     - returns:
     String that represents the route, domain, like _"/module-name"_
     */
    var route: String { get }
    
    var paths: [String] { get }
    
    /**
     Function has to implement start of the module
     
     - parameters:
     - parameters: Simple dictionary of parameters
     - path: Path which is later recognised by specific module and converted to possible method
     */
    func open(parameters: ModuleParameters?,
              path: String?,
              callback: ModuleCallback?)
}

/**
 This interface defines few simple steps:
    - store the module route, so it can be accessed many times
    - route the request sent to the module with parameters to desired functionality which is encapsulated in the module
 */
protocol ModuleRouter {
    
    var route: String { get set }
    init(route: String)
    
    func route(parameters: ModuleParameters?,
               path: String?,
               callback: ModuleCallback?)
}







