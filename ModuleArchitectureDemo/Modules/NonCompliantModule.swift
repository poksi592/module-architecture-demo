//
//  NonCompliantModule.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 05/05/2018.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation

class NonCompliantModule {
    
    func login(username: String,
               password: String,
               completion: ((String?, Error?) -> Void)?) {
        
        let service = NetworkService()
        service.post(host: "login",
                     path: "/login",
                     parameters: ["username": "myUsername",
                                  "password": "myPassword"]) { (response, urlResponse, error) in
                        
                        // We are not going to check errors and URL response status codes, just a shortest path.
                        var networkError: ResponseError? = nil
                        if let error = error {
                            networkError = ResponseError(error: error, response: urlResponse)
                        }
                        let token = response?["bearerToken"] as? String
                        
                        completion?(token, networkError)
        }
    }
}
