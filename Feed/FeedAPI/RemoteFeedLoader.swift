//
//  RemoteFeedLoader.swift
//  Feed
//
//  Created by Сергей Копаницкий on 22.01.2023.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping ((Result<HTTPURLResponse, Error>) -> Void))
}

public final class RemoteFeedLoader {
    
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping ((Error) -> Void)) {
        client.get(from: url) { result in
            switch result {
            case .success(let response):
                completion(.invalidData)
            case .failure(let error):
                completion(.connectivity)
            }
        }
    }
}
