//
//  FeedImageCellController.swift
//  FeediOS
//
//  Created by Сергей Копаницкий on 13.03.2023.
//

import UIKit

final class FeedImageCellController {
    private let viewModel: FeedImageViewModel<UIImage>
    
    init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view() -> UITableViewCell {
        let cell = binded(FeedImageCell())
        viewModel.loadImage()
        return cell
    }
    
    func preload() {
        viewModel.preloadImage()
    }
    
    func cancelLoad() {
        viewModel.cancelLoadImage()
    }
    
    private func binded(_ cell: FeedImageCell) -> FeedImageCell {
        cell.descriptionLabel.text = viewModel.description
        cell.locationLabel.text = viewModel.location
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.feedImageView.image = nil
        
        viewModel.onLoadingStateChange = { [weak cell] isLoading in
            cell?.feedImageContainer.isShimmering = isLoading
        }
        
        viewModel.onShowRetryButtonStateChange = { [weak cell] shouldShow in
            cell?.retryButton.isHidden = !shouldShow
        }
        
        viewModel.onImageDataLoad = { [weak cell] image in
            cell?.feedImageView.image = image
        }
        
        cell.onRetryAction = viewModel.loadImage
        
        return cell
    }
}
