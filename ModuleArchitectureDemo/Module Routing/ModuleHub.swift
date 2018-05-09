//
//  ModuleHub.swift
//  TandemApp
//
//  Created by Mladen Despotovic on 12/05/2017.
//  Copyright © 2017 Mladen Despotovic. All rights reserved.
//

import Foundation
import UIKit

public typealias ModuleParameters = [String: String]
public typealias ModuleCallback = ([String: Any]?, Data?, URLResponse?, Error?) -> Void


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
 Protocol defines application router, which function is
 
 - setup application module
 - fire up the app with starting first module
 */
protocol ApplicationRouterType: class {
    
//    /**
//     Function returns application schema from Info.plist
//
//     - parameters:
//     - bundle: if `nil`, then main Bundle is used
//     */
//    func urlsSchemaExists(for schema: String, bundle: Bundle?) -> Bool
    
    var instantiatedModules: [ModuleType] { get set }
    
    func open(url: URL,
              callback: ModuleCallback?)
    
    
    var moduleQueue: DispatchQueue { get }
}

extension ApplicationRouterType {
    
    func open(url: URL,
              callback: ModuleCallback?) {
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                let route = components.host else {
                return
        }
        
        guard let module = instantiatedModules.filter({ $0.route == route }).first,
                let path = module.paths.filter({ $0 == url.path }).first else {
            return
        }
        
        module.open(parameters: components.queryItemsDictionary, path: path) { (response, data, urlResponse, error) in
            
            print("awefwqef")
        }
        
    }
}

class ApplicationRouter: ApplicationRouterType {
    
    // TODO: This is synchronising only write access, which might be inadequate in many cases
    // Need to be replaced with proper full generic implementation of synchronized collection
    private (set) var moduleQueue = DispatchQueue(label: "com.tandem.module.queue")
    
    // ApplicationRouter is a singleton, because it makes it easier to be accessed from anywhere to access its functions/services
    static let shared = ApplicationRouter()

    var instantiatedModules: [ModuleType] = [PaymentModule(),
                                            LoginModule()]
}

class ApplicationServices {
    
    // ApplicationServices is a singleton, because it makes it easier to be accessed from anywhere to access its functions/services
    static let shared = ApplicationServices()
    let appRouter = ApplicationRouter()
    
    func pay(amount: Double,
             username: String,
             password: String,
             completion: @escaping (() -> Void)) {
        
        // Get payment token from `LoginModule` with `username` and `password`
        guard let moduleUrl = URL(schema: "tandem",
                                  host: "login",
                                  path: "/payment-token",
                                  parameters: ["username": username,
                                               "password": password]) else {
            return
        }
        appRouter.open(url: moduleUrl) { [weak self] (response, responseData, urlResponse, error) in
            
            // Use `token` in response to make an actual payment through `PaymentsModule`
            guard let moduleUrl = URL(schema: "tandem",
                                      host: "payments",
                                      path: "/pay",
                                      parameters: ["token": username,
                                                   "amount": String(amount)]) else {
                                                    return
            }
            self?.appRouter.open(url: moduleUrl) { (response, responseData, urlResponse, error) in
                
                // Final callback, basically just to synchronize our example here with the NonCompliantModule
                completion()
            }
        }

    }
}

@objc class URLRouter: URLProtocol, URLSessionDataDelegate, URLSessionTaskDelegate {
    
    // TODO: This is synchronisyng only write access, which might be inadequate in many cases
    // Need to be replaced with proper full generic implementation of synchronized collection
    private (set) var moduleQueue = DispatchQueue(label: "com.tandem.module.queue")
    
    // MARK: URLProtocol methods overriding
    
    override class func canInit(with task: URLSessionTask) -> Bool {

        // Check if there's internal app schema that matches the one in the URL
        guard let url = task.originalRequest?.url,
                url.containsInAppSchema() else {
            return false
        }

        // Check if there's a path in the module that matches the one in the URL
        guard let module = ApplicationRouter.shared.instantiatedModules.filter({ $0.route == task.originalRequest?.url?.host }).first,
                let _ = module.paths.filter({ $0 == task.originalRequest?.url?.path }).first else {
                return false
        }
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
 
    
    override func startLoading() {
        
        guard let url = request.url else {
            return
        }
        
        ApplicationRouter.shared.open(url: url) { (response, data, urlResponse, error) in

            print("rqerfqwe")
        }
    }
    
    override func stopLoading() {
        
    }
}





