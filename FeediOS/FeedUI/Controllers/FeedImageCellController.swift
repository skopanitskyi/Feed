//
//  FeedImageCellController.swift
//  FeediOS
//
//  Created by Сергей Копаницкий on 13.03.2023.
//

import UIKit
import Feed

final class FeedImageCellController {
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.descriptionLabel.text = model.description
        cell.locationLabel.text = model.location
        cell.locationContainer.isHidden = model.location == nil
        
        cell.feedImageView.image = nil
        
        let loadImage = { [weak self] in
            guard let self = self else { return }
            self.task = self.imageLoader.loadImage(from: self.model.url) { [weak cell] result in
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
            cell.feedImageContainer.startShimmering()
        }
        
        loadImage()
        
        cell.onRetryAction = loadImage
        
        return cell
    }
    
    func preload() {
        task = imageLoader.loadImage(from: model.url) { _ in }
    }
    
    func cancelLoad() {
        task?.cancel()
    }
}
