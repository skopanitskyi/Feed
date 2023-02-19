//
//  ManagedFeedCache+CoreDataProperties.swift
//  Feed
//
//  Created by Сергей Копаницкий on 18.02.2023.
//
//

import Foundation
import CoreData


extension ManagedFeedCache {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedFeedCache> {
        return NSFetchRequest<ManagedFeedCache>(entityName: "ManagedFeedCache")
    }

    @NSManaged public var timestamp: Date
    @NSManaged public var feed: NSOrderedSet?

}

// MARK: Generated accessors for feed
extension ManagedFeedCache {

    @objc(insertObject:inFeedAtIndex:)
    @NSManaged public func insertIntoFeed(_ value: ManagedFeed, at idx: Int)

    @objc(removeObjectFromFeedAtIndex:)
    @NSManaged public func removeFromFeed(at idx: Int)

    @objc(insertFeed:atIndexes:)
    @NSManaged public func insertIntoFeed(_ values: [ManagedFeed], at indexes: NSIndexSet)

    @objc(removeFeedAtIndexes:)
    @NSManaged public func removeFromFeed(at indexes: NSIndexSet)

    @objc(replaceObjectInFeedAtIndex:withObject:)
    @NSManaged public func replaceFeed(at idx: Int, with value: ManagedFeed)

    @objc(replaceFeedAtIndexes:withFeed:)
    @NSManaged public func replaceFeed(at indexes: NSIndexSet, with values: [ManagedFeed])

    @objc(addFeedObject:)
    @NSManaged public func addToFeed(_ value: ManagedFeed)

    @objc(removeFeedObject:)
    @NSManaged public func removeFromFeed(_ value: ManagedFeed)

    @objc(addFeed:)
    @NSManaged public func addToFeed(_ values: NSOrderedSet)

    @objc(removeFeed:)
    @NSManaged public func removeFromFeed(_ values: NSOrderedSet)

}

extension ManagedFeedCache : Identifiable {

}
