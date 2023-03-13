//
//  FeedViewController.swift
//  FeediOS
//
//  Created by Сергей Копаницкий on 10.03.2023.
//

import UIKit
import Feed

public final class FeedViewController: UITableViewController {
    
    private var feedRefreshController: FeedRefreshController?
    private var imageLoader: FeedImageDataLoader?
    
    private var tableModels: [FeedImage] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    private var imageLoadingTasks: [IndexPath: FeedImageDataLoaderTask] = [:]
    
    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.feedRefreshController = FeedRefreshController(feedLoader: feedLoader)
        self.imageLoader = imageLoader
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(FeedImageCell.self, forCellReuseIdentifier: String(describing: FeedImageCell.self))

        tableView.prefetchDataSource = self
        
        tableView.refreshControl = feedRefreshController?.refreshControl
        
        feedRefreshController?.onLoad = { [weak self] feed in
            self?.tableModels = feed
        }
        
        feedRefreshController?.refresh()
    }
    
    private func cancelTask(forRowAt indexPath: IndexPath) {
        imageLoadingTasks[indexPath]?.cancel()
        imageLoadingTasks[indexPath] = nil
    }
}

extension FeedViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModels.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: FeedImageCell.self),
            for: indexPath) as! FeedImageCell
        
        let model = tableModels[indexPath.row]
        cell.descriptionLabel.text = model.description
        cell.locationLabel.text = model.location
        cell.locationContainer.isHidden = model.location == nil
        
        cell.feedImageView.image = nil
        
        let loadImage = { [weak self] in
            guard let self = self else { return }
            let task = self.imageLoader?.loadImage(from: model.url) { [weak cell] result in
                switch result {
                case .success(let data):
                    let image = UIImage(data: data)
                    cell?.feedImageView.image = image
                    cell?.retryButton.isHidden = image != nil
                case .failure:
                    cell?.retryButton.isHidden = false
                }
                
                cell?.feedImageContainer.stopShimmering()
            }
            self.imageLoadingTasks[indexPath] = task
            cell.feedImageContainer.startShimmering()
        }
        
        loadImage()
        
        cell.onRetryAction = loadImage
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(forRowAt: indexPath)
        (cell as? FeedImageCell)?.stopShimmering()
    }
}

extension FeedViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let model = tableModels[indexPath.row]
            imageLoadingTasks[indexPath] = imageLoader?.loadImage(from: model.url) { _ in }
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }
}
