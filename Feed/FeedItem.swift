//
//  FeedItem.swift
//  Feed
//
//  Created by Сергей Копаницкий on 19.01.2023.
//

import Foundation

struct FeedItem {
    public let uuid: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
}
