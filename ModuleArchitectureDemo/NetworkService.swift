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
    
    func get(host: String,
             path: String,
             parameters: [String: Any]?,
             completion: @escaping ([String: Any]?, HTTPURLResponse?, Error?) -> Void) {
        
        guard let urlRequest = request(host: host,
                                       path: path,
                                       parameters: parameters) else {
            return
        }
        
        http(urlRequest: urlRequest, completion: completion)
    }
    
    func post(host: String,
             path: String,
             parameters: [String: Any]?,
             completion: @escaping ([String: Any]?, HTTPURLResponse?, Error?) -> Void) {
        
        guard let urlRequest = request(host: host,
                                       path: path,
                                       parameters: parameters,
                                       httpMethod: HTTPMethod.POST.rawValue) else {
            return
        }
        
        http(urlRequest: urlRequest, completion: completion)
    }
    
    private func http(urlRequest: URLRequest,
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
    
    private func request(host: String,
                         path: String,
                         parameters: [String: Any]?,
                         httpMethod: String? = HTTPMethod.GET.rawValue) -> URLRequest? {
        
        var components = URLComponents()
        components.scheme = "tandem"
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




