//
//  FeedLoader.swift
//  Feed
//
//  Created by Сергей Копаницкий on 19.01.2023.
//

import Foundation

protocol FeedLoader {
    func fetchFeeds(completion: @escaping ((Result<[FeedItem], Error>) -> Void))
}
