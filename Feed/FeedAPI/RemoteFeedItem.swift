//
//  RemoteFeedItem.swift
//  Feed
//
//  Created by Сергей Копаницкий on 04.02.2023.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
