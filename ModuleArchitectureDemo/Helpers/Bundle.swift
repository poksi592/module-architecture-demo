//
//  Bundle.swift
//  TandemApp
//
//  Created by Mladen Despotovic on 22/06/2017.
//  Copyright © 2017 Tandem Bank. All rights reserved.
//

import Foundation

extension Bundle {
    
    var urlSchemes: [String]? {
        
        get {
            guard let urlTypes = self.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: AnyObject]] else {
                return nil
            }
            let urlSchemes = urlTypes.compactMap { (item) -> [String]? in
                
                guard let schemes = item["CFBundleURLSchemes"] as? [String] else {
                    
                    return nil
                }
                return schemes
            }
            return urlSchemes.flatMap { $0 }
        }
    }
}
