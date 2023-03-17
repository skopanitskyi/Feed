//
//  FeedImageViewModel.swift
//  FeediOS
//
//  Created by Сергей Копаницкий on 17.03.2023.
//

import Foundation
import Feed

final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private let imageTransformer: (Data) -> Image?
    
    private var task: FeedImageDataLoaderTask?
    
    public var onImageDataLoad: Observer<Image>?
    public var onLoadingStateChange: Observer<Bool>?
    public var onShowRetryButtonStateChange: Observer<Bool>?
    
    public var description: String? {
        return model.description
    }
    
    public var location: String? {
        return model.location
    }
    
    public var hasLocation: Bool {
        return model.location != nil
    }
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    public func loadImage() {
        onShowRetryButtonStateChange?(false)
        onLoadingStateChange?(true)
        
        task = imageLoader.loadImage(from: model.url) { [weak self] result in
            guard let self = self else { return }
            if let image = (try? result.get()).flatMap(self.imageTransformer) {
                self.onImageDataLoad?(image)
            } else {
                self.onShowRetryButtonStateChange?(true)
            }
            self.onLoadingStateChange?(false)
        }
    }
    
    public func preloadImage() {
        task = imageLoader.loadImage(from: model.url) { _ in }
    }
    
    public func cancelLoadImage() {
        task?.cancel()
    }
}
