//
//  LocalFeedImage.swift
//  Feed
//
//  Created by Сергей Копаницкий on 04.02.2023.
//

import Foundation

public struct LocalFeedImage: Equatable {
    public let uuid: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    public init(
        uuid: UUID,
        description: String?,
        location: String?,
        url: URL) {
            self.uuid = uuid
            self.description = description
            self.location = location
            self.url = url
        }
}
