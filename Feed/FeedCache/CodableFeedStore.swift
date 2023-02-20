//
//  CodableFeedStore.swift
//  Feed
//
//  Created by Сергей Копаницкий on 11.02.2023.
//

import Foundation

private struct Cache: Codable {
    let feed: [CodableFeedImage]
    let timestamp: Date
    
    var toLocal: [LocalFeedImage] {
        return feed.map { .init(uuid: $0.uuid, description: $0.description, location: $0.location, url: $0.url) }
    }
}

private struct CodableFeedImage: Codable {
    public let uuid: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    init(_ feed: LocalFeedImage) {
        uuid = feed.uuid
        description = feed.description
        location = feed.location
        url = feed.url
    }
}

public final class CodableFeedStore: FeedStore {
    private let storeQueue = DispatchQueue(label: "Cache feed queue", attributes: .concurrent)
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrive(completion: @escaping RetriveCompletion) {
        let storeURL = self.storeURL
        
        storeQueue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.success(nil))
            }
            
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(Cache.self, from: data)
                completion(.success(.init(feed: decoded.toLocal, timestamp: decoded.timestamp)))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        
        storeQueue.async(flags: .barrier) {
            let encoder = JSONEncoder()
            let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
            
            do {
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        
        storeQueue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(.success(()))
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
