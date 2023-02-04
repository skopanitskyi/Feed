//
//  FeedLoader.swift
//  Feed
//
//  Created by Сергей Копаницкий on 19.01.2023.
//

import Foundation

public enum FeedLoaderResponse {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (FeedLoaderResponse) -> Void)
}
