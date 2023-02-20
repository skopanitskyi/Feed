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
        store.deleteCacheFeed { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.cache(feed, with: completion)
            case .failure(let error):
                completion?(error)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: ((SaveResult) -> Void)?) {
        store.insert(feed.toLocal(), timestamp: self.currnentDate()) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case .success:
                completion?(nil)
            case .failure(let error):
                completion?(error)
            }            
        }
    }
}

extension LocalFeedLoader {
    public typealias RetriveResult = FeedLoader.Response
    
    public func load(completion: @escaping (RetriveResult) -> Void) {
        store.retrive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(.some(let cache)) where FeedCachePolicy.validate(cache.timestamp, against: self.currnentDate()):
                completion(.success(cache.feed.toModels()))
            case .success(.none),
                 .success(.some):
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
            case .success(.some(let cache)) where !FeedCachePolicy.validate(cache.timestamp, against: self.currnentDate()):
                self.store.deleteCacheFeed { _ in }
            case .success(.none),
                 .success(.some):
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
