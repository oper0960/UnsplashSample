//
//  NetworkManager.swift
//  UnsplashSample
//
//  Created by Gilwan Ryu on 2020/06/25.
//  Copyright © 2020 GilwanRyu. All rights reserved.
//

import UIKit

typealias DictionaryType = [String: Any]
typealias headersType = [String: String]

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum URLRequestError: Error {
    case notFoundRequest
}

class NetworkManager {
    private let config = URLSessionConfiguration.default
    private var session: URLSession {
        return URLSession(configuration: config)
    }

    private func getURLRequest(url: String, parameters: DictionaryType) -> URLRequest? {
        
        guard var components = URLComponents(string: url) else { return nil }
        
        components.queryItems = parameters.map { (item) -> URLQueryItem in
            return URLQueryItem(name: item.key, value: item.value as? String)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        guard let resultUrl = components.url else { return nil }
        
        return URLRequest(url: resultUrl)
    }
    
    private func postURLRequest(url: String, parameters: DictionaryType) -> URLRequest? {
        
        guard let url = URL(string: url) else { return nil }
        
        var request = URLRequest(url: url)
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch {
            return nil
        }
        return request
    }
    
    private func createRequest(for urlString: String, method: HTTPMethod, headers: headersType, parameters: DictionaryType) -> URLRequest? {
        
        switch method {
        case .get:
            guard var request = getURLRequest(url: urlString, parameters: parameters) else { return nil }
            request.httpMethod = method.rawValue
            return request
        case .post:
            guard var request = postURLRequest(url: urlString, parameters: parameters) else { return nil }
            request.httpMethod = method.rawValue
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
            return request
        }
    }
    
    func request<T: Codable>(for urlString: String, method: HTTPMethod, headers: headersType, parameters: DictionaryType, completion: @escaping (T?, Error?) -> ()) {
        
        guard let request = createRequest(for: urlString, method: method, headers: headers, parameters: parameters) else {
            completion(nil,URLRequestError.notFoundRequest)
            return
        }
        
        session.dataTask(with: request) { data, response, error in
        if let data = data {
            do {
                let codable = try JSONDecoder().decode(T.self, from: data)
                completion(codable, nil)
            } catch let error {
                completion(nil, error)
            }
        } else {
            completion(nil,error)
        }}.resume()
    }
}
