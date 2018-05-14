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
