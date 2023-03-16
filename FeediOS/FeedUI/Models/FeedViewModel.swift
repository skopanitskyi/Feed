//
//  FeedViewModel.swift
//  FeediOS
//
//  Created by Сергей Копаницкий on 16.03.2023.
//

import Foundation
import Feed

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
        
    private let feedLoader: FeedLoader
    
    public var onFeedLoad: Observer<[FeedImage]>?
    public var onLoadingStateChange: Observer<Bool>?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
        
    public func fetch() {
        onLoadingStateChange?(true)
        
        feedLoader.load { [weak self] result in
            if let feeds = try? result.get() {
                self?.onFeedLoad?(feeds)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
