//
//  FeedImageDataLoader.swift
//  FeediOS
//
//  Created by Сергей Копаницкий on 13.03.2023.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    func loadImage(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> FeedImageDataLoaderTask
}
