//
//  URLExtensions.swift
//  TandemApp
//
//  Created by Mladen Despotovic on 17/05/2017.
//  Copyright © 2017 Tandem. All rights reserved.
//

import Foundation

extension URL {
    
    init?(schema: String,
          host: String,
          path: String? = nil,
          parameters: [String: String]? = nil) {
        
        var components = URLComponents()
        components.scheme = schema
        components.host = host
        components.path = path ?? ""
        
        let queryItems = parameters?.map {  key, value -> URLQueryItem in
            
            return URLQueryItem.init(name: key, value: value)
        }
        components.queryItems = queryItems
        
        if let url = components.url {
            self = url
        }
        else {
            return nil
        }
    }
    
    /**
     This extension uses resource from URL in main bundle and converts it to JSON dictionary.
     
     - returns: `[String: Any]?`
    */
    func jsonFromMainBundle() -> [String: Any]? {
        
        do {
            let data = try Data(contentsOf: self)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            return json as? [String: Any]
        } catch {
            return nil
        }
    }
    
    func containsInAppSchema(for bundle: Bundle? = Bundle.main) -> Bool {
        
        guard let schemes = bundle?.urlSchemes else {
            return false
        }
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
            let scheme = components.scheme else {
                
                return false
        }
        return schemes.filter { $0 == scheme }.count > 0
    }
    
    var isHttpAddress: Bool {
        
        get {
            if let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
                let scheme = components.scheme,
                let _ = components.host,
                scheme == "http" || scheme == "https" {
                
                return true
            }
            else {
                return false
            }
        }
    }
}

extension URLComponents {
    
    var queryItemsDictionary: [String: String]? {
        var params = [String: String]()
        return self.queryItems?.reduce([:], { (_, item) -> [String: String] in
            
                params[item.name] = item.value
                return params
        })
    }
}
