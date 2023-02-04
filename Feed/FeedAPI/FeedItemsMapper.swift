//
//  FeedItemsMapper.swift
//  Feed
//
//  Created by Сергей Копаницкий on 25.01.2023.
//

import Foundation

final class FeedItemsMapper {
    
    private static let validStatusCode = 200
    
    private struct FeedItemsJSON: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem]  {
        guard response.statusCode == validStatusCode,
              let json = try? JSONDecoder().decode(FeedItemsJSON.self, from: data) else {
                  throw RemoteFeedLoader.Error.invalidData
              }
        
        return json.items
    }
}
