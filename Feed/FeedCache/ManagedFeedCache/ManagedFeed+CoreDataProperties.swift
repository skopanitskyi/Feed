//
//  ManagedFeed+CoreDataProperties.swift
//  Feed
//
//  Created by Сергей Копаницкий on 18.02.2023.
//
//

import Foundation
import CoreData


extension ManagedFeed {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedFeed> {
        return NSFetchRequest<ManagedFeed>(entityName: "ManagedFeed")
    }

    @NSManaged public var id: UUID
    @NSManaged public var location: String?
    @NSManaged public var url: URL
    @NSManaged public var info: String?
    @NSManaged public var cache: ManagedFeedCache?

}

extension ManagedFeed : Identifiable {

}
