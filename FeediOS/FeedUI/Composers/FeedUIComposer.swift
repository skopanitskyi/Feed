//
//  FeedUIComposer.swift
//  FeediOS
//
//  Created by Сергей Копаницкий on 13.03.2023.
//

import Feed

public final class FeedUIComposer {
    
    private init() { }
    
    public static func feedComposeFeedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedRefreshController = FeedRefreshController(feedLoader: feedLoader)
        let feedViewController = FeedViewController(feedRefreshController: feedRefreshController)
                
        feedRefreshController.onLoad = adaptFeedToCellControllers(forwardingTo: feedViewController, loader: imageLoader)
        
        return feedViewController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { feed in
            controller.tableModels = feed.map { FeedImageCellController(model: $0, imageLoader: loader) }
        }
    }
}
