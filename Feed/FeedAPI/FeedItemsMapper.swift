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
        let items: [Item]
        
        var feedItems: [FeedItem] {
            return items.map { $0.feedItem }
        }
    }
    
    private struct Item: Decodable {
        let uuid: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var feedItem: FeedItem {
            FeedItem(uuid: uuid, description: description, location: location, imageURL: image)
        }
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Response {
        guard response.statusCode == validStatusCode,
              let items = try? JSONDecoder().decode(FeedItemsJSON.self, from: data) else {
                  return .failure(RemoteFeedLoader.Error.invalidData)
              }
        
        return .success(items.feedItems)
    }
}
