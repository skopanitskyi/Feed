//
//  FeedLoader.swift
//  Feed
//
//  Created by Сергей Копаницкий on 19.01.2023.
//

import Foundation

public protocol FeedLoader {
    typealias Response = Result<[FeedImage], Error>

    func load(completion: @escaping (Response) -> Void)
}
