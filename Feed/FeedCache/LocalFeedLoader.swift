//
//  LocalFeedLoader.swift
//  Feed
//
//  Created by Сергей Копаницкий on 04.02.2023.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currnentDate: () -> Date
    
    public typealias SaveResult = Error?
    
    public init(store: FeedStore, currnentDate: @escaping () -> Date) {
        self.store = store
        self.currnentDate = currnentDate
    }
    
    public func save(_ feed: [FeedImage], completion: ((SaveResult) -> Void)? = nil) {
        store.deleteCacheFeed { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletingError = error {
                completion?(cacheDeletingError)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: ((SaveResult) -> Void)?) {
        store.insert(feed.toLocal(), timestamp: self.currnentDate()) { [weak self] error in
            guard self != nil else { return }
            completion?(error)
        }
    }
}

extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map {
            return .init(uuid: $0.uuid, description: $0.description, location: $0.location, url: $0.url)
        }
    }
}
