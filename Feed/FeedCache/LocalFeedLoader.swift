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
    private let maxCacheAgeInDays = 7
    
    public typealias SaveResult = Error?
    public typealias RetriveResult = FeedLoaderResponse
    
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
    
    public func retrive(competion: ((RetriveResult) -> Void)? = nil) {
        store.retrive { [weak self ]result in
            guard let self = self else { return }
            
            switch result {
            case .found(let feed, let timestamp) where self.validate(timestamp):
                competion?(.success(feed.toModels()))
            case .found, .empty:
                competion?(.success([]))
            case .failure(let error):
                competion?(.failure(error))
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: ((SaveResult) -> Void)?) {
        store.insert(feed.toLocal(), timestamp: self.currnentDate()) { [weak self] error in
            guard self != nil else { return }
            completion?(error)
        }
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = Calendar.current.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        
        return currnentDate() < maxCacheAge
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
