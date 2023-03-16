//
//  FeedRefreshController.swift
//  FeediOS
//
//  Created by Сергей Копаницкий on 13.03.2023.
//

import UIKit

final class FeedRefreshController: NSObject {
    
    private(set) lazy var refreshControl: UIRefreshControl = {
        return binded(UIRefreshControl())
    }()
    
    private let viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    @objc
    public func refresh() {
        viewModel.fetch()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onLoadingStateChange = { [weak view] isLoading in
            if isLoading {
                view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }
        }

        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
