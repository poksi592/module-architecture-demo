//
//  NetworkService.swift
//  APIClientArchitectureDemo
//
//  Created by Mladen Despotovic on 26/03/2018.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    
    case GET
    case POST
}

class NetworkService {
    
    func get(scheme: String? = nil,
             host: String,
             path: String,
             parameters: [String: Any]?,
             completion: @escaping ([String: Any]?, HTTPURLResponse?, Error?) -> Void) {
        
        guard let urlRequest = request(scheme: scheme,
                                       host: host,
                                       path: path,
                                       parameters: parameters) else {
            return
        }
        
        service(urlRequest: urlRequest, completion: completion)
    }
    
    func post(scheme: String? = nil,
              host: String,
              path: String,
              parameters: [String: Any]?,
              completion: @escaping ([String: Any]?, HTTPURLResponse?, Error?) -> Void) {
        
        guard let urlRequest = request(scheme: scheme,
                                       host: host,
                                       path: path,
                                       parameters: parameters,
                                       httpMethod: HTTPMethod.POST.rawValue) else {
            return
        }
        
        service(urlRequest: urlRequest, completion: completion)
    }
    
    private func service(urlRequest: URLRequest,
                         completion: @escaping ([String: Any]?, HTTPURLResponse?, Error?) -> Void) {
    
        let configuration = URLSessionConfiguration.`default`
        configuration.protocolClasses?.append(URLRouter.self)
        let session = URLSession(configuration: configuration)
        
        session.dataTask(with: urlRequest) { (data, urlResponse, error) in
            
            var responseBody: [String: Any]? = nil
            
            if let data = data {
                do {
                    responseBody = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                } catch {
                    responseBody = nil
                }
            }
            completion(responseBody, urlResponse as? HTTPURLResponse, error)
            
            }.resume()
    }
    
    private func request(scheme: String? = nil,
                         host: String,
                         path: String,
                         parameters: [String: Any]?,
                         httpMethod: String? = HTTPMethod.GET.rawValue) -> URLRequest? {
        
        var components = URLComponents()
        components.scheme = scheme ?? "http"
        components.host = host
        components.path = path
        
        if let parameters = parameters {
            components.queryItems = parameters.compactMap { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
        }
        guard let requestUrl = components.url else {
            return nil
        }
        
        var urlRequest = URLRequest(url: requestUrl)
        urlRequest.httpMethod = httpMethod
        
        return urlRequest
    }
}




