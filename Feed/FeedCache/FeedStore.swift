//
//  FeedStore.swift
//  Feed
//
//  Created by Сергей Копаницкий on 04.02.2023.
//

import Foundation

public enum RetriveCachedFeedResult {
    case failure(Error)
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
}

public protocol FeedStore {
    typealias DeletionCompletion = ((Error?) -> Void)
    typealias InsertionCompletion = ((Error?) -> Void)
    typealias RetriveCompletion = ((RetriveCachedFeedResult) -> Void)
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrive(completion: @escaping RetriveCompletion)
}
