//
//  FeedCacheHelpers.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 05.02.2023.
//

import Foundation
import Feed
import XCTest

func createImageFeed() -> (items: [FeedImage], localFeed: [LocalFeedImage]) {
    let feed1 = FeedImage(uuid: UUID(), description: "test", location: "location 1", url: makeURL())
    let feed2 = FeedImage(uuid: UUID(), description: "test 2", location: "location 2", url: makeURL())
    let feed = [feed1, feed2]
    let localFeed = feed.map {
        return LocalFeedImage(
            uuid: $0.uuid,
            description: $0.description,
            location: $0.location,
            url: $0.url)
    }
    
    return (items: feed, localFeed: localFeed)
}

extension Date {
    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(second: Int) -> Date {
        return Calendar.current.date(byAdding: .second, value: second, to: self)!
    }
}
