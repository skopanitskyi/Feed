//
//  FeedItem.swift
//  Feed
//
//  Created by Сергей Копаницкий on 19.01.2023.
//

import Foundation

public struct FeedItem: Equatable {
    public let uuid: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(
        uuid: UUID,
        description: String?,
        location: String?,
        imageURL: URL) {
            self.uuid = uuid
            self.description = description
            self.location = location
            self.imageURL = imageURL
        }
}
