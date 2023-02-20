//
//  CoreDataFeedStore.swift
//  Feed
//
//  Created by Сергей Копаницкий on 12.02.2023.
//

import CoreData

final public class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init (storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "ManagedFeedCache", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        context.performAndWait {
            completion(Result {
                try ManagedFeed.deleteAll(context)
            })
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        context.performAndWait {
            completion(Result {
                try ManagedFeed.save(feed, timestamp: timestamp, in: context)
            })
        }
    }
    
    public func retrive(completion: @escaping RetriveCompletion) {
        let context = self.context
        
        context.perform {
            completion(Result {
                try ManagedFeed.fetchFeed(context).map { feedCache in
                    return CachedFeed(feed: feedCache.feed, timestamp: feedCache.timestamp)
                }
            })
        }
    }
}

private extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
     }
    
    static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Error?
        container.loadPersistentStores { loadError = $1 }
        
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }
        
        return container
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle.url(forResource: name, withExtension: "momd").flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}

private extension ManagedFeed {
    static func feed(for feed: [LocalFeedImage], content: NSManagedObjectContext) -> [ManagedFeed] {
        return feed.map { item in
            let managedFeed = ManagedFeed(context: content)
            managedFeed.id = item.uuid
            managedFeed.info = item.description
            managedFeed.location = item.location
            managedFeed.url = item.url
            return managedFeed
        }
    }
}

private extension ManagedFeed {
    static func deleteAll(_ context: NSManagedObjectContext) throws {
        let fetchRequest: NSFetchRequest<ManagedFeedCache> = ManagedFeedCache.fetchRequest()
        let feedCaches = try context.fetch(fetchRequest)

        for feedCache in feedCaches {
            context.delete(feedCache)
        }
        
        try context.save()
    }
}

private extension ManagedFeed {
    static func save(_ feed: [LocalFeedImage], timestamp: Date, in context: NSManagedObjectContext) throws {
        let cache = ManagedFeedCache(context: context)
        let feed = ManagedFeed.feed(for: feed, content: context)
        cache.timestamp = timestamp

        cache.feed = NSOrderedSet(array: feed)
        try context.save()
    }
}

private extension ManagedFeed {
    static func fetchFeed(_ context: NSManagedObjectContext) throws -> (feed: [LocalFeedImage], timestamp: Date)? {
        let fetchRequest: NSFetchRequest<ManagedFeedCache> = ManagedFeedCache.fetchRequest()
        let feedCaches = try context.fetch(fetchRequest)
        
        guard let feedCache = feedCaches.last else { return nil }
        
        let feed = feedCache.feed?.array.compactMap { $0 as? ManagedFeed }.toLocal() ?? []
        return (feed: feed, timestamp: feedCache.timestamp)
    }
}

private extension Array where Element == ManagedFeed {
    func toLocal() -> [LocalFeedImage] {
        return map {
            return .init(uuid: $0.id, description: $0.info, location: $0.location, url: $0.url)
        }
    }
}
