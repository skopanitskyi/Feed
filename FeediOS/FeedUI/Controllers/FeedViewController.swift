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
    
    convenience init(feedRefreshController: FeedRefreshController) {
        self.init()
        self.feedRefreshController = feedRefreshController
    }
            
    var tableModels: [FeedImageCellController] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        tableView.prefetchDataSource = self
        
        tableView.refreshControl = feedRefreshController?.refreshControl
                
        feedRefreshController?.refresh()
    }
    
    private func cancelCellControllerLoad(at indexPath: IndexPath) {
        tableModels[indexPath.row].cancelLoad()
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        return tableModels[indexPath.row]
    }
}

extension FeedViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModels.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(at: indexPath)
    }
}

extension FeedViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
}
