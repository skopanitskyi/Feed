//
//  LocalFeedLoader.swift
//  Feed
//
//  Created by Сергей Копаницкий on 04.02.2023.
//

import Foundation

public final class LocalFeedLoader: FeedLoader {
    private let store: FeedStore
    private let currnentDate: () -> Date
    
    public init(store: FeedStore, currnentDate: @escaping () -> Date) {
        self.store = store
        self.currnentDate = currnentDate
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Error?
    
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

extension LocalFeedLoader {
    public typealias RetriveResult = FeedLoaderResponse
    
    public func load(completion: @escaping (RetriveResult) -> Void) {
        store.retrive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .found(let feed, let timestamp) where FeedCachePolicy.validate(timestamp, against: self.currnentDate()):
                completion(.success(feed.toModels()))
            case .empty, .found:
                completion(.success([]))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension LocalFeedLoader {
    public func validateCache() {
        store.retrive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCacheFeed { _ in }
            case .found(_, let timestamp) where !FeedCachePolicy.validate(timestamp, against: self.currnentDate()):
                self.store.deleteCacheFeed { _ in }
            case .empty, .found:
                break
            }
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map {
            return .init(uuid: $0.uuid, description: $0.description, location: $0.location, url: $0.url)
        }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map {
            return .init(uuid: $0.uuid, description: $0.description, location: $0.location, url: $0.url)
        }
    }
}
