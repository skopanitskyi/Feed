//
//  URLSessionHTTPClient.swift
//  Feed
//
//  Created by Сергей Копаницкий on 30.01.2023.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedError: Error { }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Response) -> Void) {
        session.dataTask(with: url) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedError()
                }
            })
        }.resume()
    }
}
