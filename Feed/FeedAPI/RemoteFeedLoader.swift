//
//  RemoteFeedLoader.swift
//  Feed
//
//  Created by Сергей Копаницкий on 22.01.2023.
//

import Foundation

public enum HTTPClientResponse {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void)
}

public final class RemoteFeedLoader {
    
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Response: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping ((Response) -> Void)) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                if let json = try? JSONDecoder().decode(FeedItemsJSON.self, from: data) {
                    completion(.success(json.items))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private struct FeedItemsJSON: Decodable {
    public let items: [FeedItem]
}
