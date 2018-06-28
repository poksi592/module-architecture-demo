//
//  ApplicationRouter.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 14/05/2018.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation

public typealias ModuleCallback = ([String: Any]?, Data?, URLResponse?, Error?) -> Void

/**
 Protocol defines application router, which function is
 
 - register application modules
 - access/open the modules
 - provide the callback, result of the access
 */
protocol ApplicationRouterType: class {
    
    var instantiatedModules: [ModuleType] { get set }
    var moduleQueue: DispatchQueue { get }
    
    func open(url: URL,
              callback: ModuleCallback?)
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
                
                assertionFailure("Wrong host or/and path")
                return
        }
        
        module.open(parameters: components.queryItemsDictionary, path: path) { (response, data, urlResponse, error) in
            
            callback?(response, data, urlResponse, error)
        }
        
    }
}

class ApplicationRouter: ApplicationRouterType {
    
    // TODO: This is synchronising only write access, which might be inadequate in many cases
    // Need to be replaced with proper full generic implementation of synchronized collection
    private (set) var moduleQueue = DispatchQueue(label: "com.tandem.module.queue")
    
    // ApplicationRouter is a singleton, because it makes it easier to be accessed from anywhere to access its functions/services
    static let shared = ApplicationRouter()
    
    // We have registered 2 modules for now...
    var instantiatedModules: [ModuleType] = [PaymentModule(),
                                             LoginModule()]
}

class ApplicationServices {
    
    // ApplicationServices is a singleton, because it makes it easier to be accessed from anywhere to access its functions/services
    static let shared = ApplicationServices()
    let appRouter = ApplicationRouter()
    
    func pay(amount: Double,
             paymentToken: String?,
             completion: @escaping (() -> Void)) {
        
        // Get payment token from `LoginModule` with `username` and `password`
        guard let moduleUrl = URL(schema: "tandem",
                                  host: "payments",
                                  path: "/pay",
                                  parameters: ["amount": String(amount),
                                               "token": paymentToken ?? "",
                                               "presentationMode": "navigationStack"]) else {
                return
        }
        appRouter.open(url: moduleUrl) { [weak self] (response, responseData, urlResponse, error) in
            
            // Use `token` in response to make an actual payment through `PaymentsModule`
            guard let response = response,
                    let token = response["paymentToken"] as? String,
                    let moduleUrl = URL(schema: "tandem",
                                        host: "payments",
                                        path: "/pay",
                                        parameters: ["token": token,
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
            
            // TODO: Calling URLSessionDataDelegate methods to return the response
        }
    }
    
    override func stopLoading() {
    }
}
