//
//  FeedStore.swift
//  Feed
//
//  Created by Сергей Копаницкий on 04.02.2023.
//

import Foundation


public struct CachedFeed {
    public let feed: [LocalFeedImage]
    public let timestamp: Date
    
    public init(feed: [LocalFeedImage], timestamp: Date) {
        self.feed = feed
        self.timestamp = timestamp
    }
}

public protocol FeedStore {
    typealias DeletionResult = Result<Void, Error>
    typealias InsertionResult = Result<Void, Error>
    typealias RetriveResult = Result<CachedFeed?, Error>
    typealias DeletionCompletion = ((DeletionResult) -> Void)
    typealias InsertionCompletion = ((InsertionResult) -> Void)
    typealias RetriveCompletion = ((RetriveResult) -> Void)
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrive(completion: @escaping RetriveCompletion)
}
