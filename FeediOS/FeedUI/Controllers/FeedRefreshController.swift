//
//  FeedRefreshController.swift
//  FeediOS
//
//  Created by Сергей Копаницкий on 13.03.2023.
//

import UIKit
import Feed

final class FeedRefreshController: NSObject {
    
    public var onLoad: (([FeedImage]) -> Void)?
    
    private(set) lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
        super.init()
    }
    
    @objc
    public func refresh() {
        refreshControl.beginRefreshing()
        
        feedLoader.load { [weak self] result in
            if let feeds = try? result.get() {
                self?.onLoad?(feeds)
            }
            self?.refreshControl.endRefreshing()
        }
    }
}
