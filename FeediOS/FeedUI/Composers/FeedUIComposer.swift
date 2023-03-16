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
        let viewModel = FeedViewModel(feedLoader: feedLoader)
        let feedRefreshController = FeedRefreshController(viewModel: viewModel)
        let feedViewController = FeedViewController(feedRefreshController: feedRefreshController)
                
        viewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedViewController, loader: imageLoader)
        
        return feedViewController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModels = feed.map { FeedImageCellController(model: $0, imageLoader: loader) }
        }
    }
}
