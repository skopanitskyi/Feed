//
//  FeedViewControllerTests.swift
//  FeediOSTests
//
//  Created by Сергей Копаницкий on 09.03.2023.
//

import XCTest
import UIKit
import Feed
import FeediOS

class FeedViewControllerTests: XCTestCase {
    
    func test_loadFeedActions_requestLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadFeedCount, 0)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadFeedCount, 1)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCount, 2)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCount, 3)
    }
    
    func test_loadingIndicatorVisible_whileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator)

        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator)

        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    func test_loadFeedCompletion_rendersLoadedFeed() {
        let feed1 = makeFeedImage(description: "feed1", location: "feed1")
        let feed2 = makeFeedImage(description: "feed2", location: "feed2")
        let feed3 = makeFeedImage()
        let feed4 = makeFeedImage(description: "feed4")
        let feed5 = makeFeedImage(location: "feed5")

        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut: sut, rendering: [])
        
        loader.completeFeedLoading(at: 0, feed: [feed1])
        assertThat(sut: sut, rendering: [feed1])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(at: 1, feed: [feed1, feed2, feed3, feed4, feed5])
        assertThat(sut: sut, rendering: [feed1, feed2, feed3, feed4, feed5])
    }
    
    func test_loadFeedCompletion_doesNotAlterRenderedFeedOnError() {
        let image = makeFeedImage()
        
        let (sut, feedLoader) = makeSUT()
        sut.loadViewIfNeeded()
        
        feedLoader.completeFeedLoading(at: 0, feed: [image])
        assertThat(sut: sut, rendering: [image])
        
        feedLoader.completeFeedLoadingWithError(at: 0)
        
        assertThat(sut: sut, rendering: [image])
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let image1 = makeFeedImage(url: URL(string: "https://google.com")!)
        let image2 = makeFeedImage(url: URL(string: "https://test.com")!)

        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(at: 0, feed: [image1, image2])

        XCTAssertEqual(loader.loadedImageURLs, [])
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image1.url])
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image1.url, image2.url])
    }
    
    func test_feedImageView_cancelesImageLoadingWhenViewNotVisibleAnymore() {
        let image1 = makeFeedImage(url: URL(string: "https://google.com")!)
        let image2 = makeFeedImage(url: URL(string: "https://test.com")!)

        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(at: 0, feed: [image1, image2])

        XCTAssertEqual(loader.cancelledLoadURLs, [])
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledLoadURLs, [image1.url])
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledLoadURLs, [image1.url, image2.url])
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let image1 = makeFeedImage()
        let image2 = makeFeedImage()

        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(at: 0, feed: [image1, image2])
        
        let view1 = sut.simulateFeedImageViewVisible(at: 0)
        let view2 = sut.simulateFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true)
        XCTAssertEqual(view2?.isShowingImageLoadingIndicator, true)

        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false)
        XCTAssertEqual(view2?.isShowingImageLoadingIndicator, true)
        
        loader.completeImageLoading(at: 1)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false)
        XCTAssertEqual(view2?.isShowingImageLoadingIndicator, false)
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let image1 = makeFeedImage()
        let image2 = makeFeedImage()

        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(at: 0, feed: [image1, image2])
        
        let view1 = sut.simulateFeedImageViewVisible(at: 0)
        let view2 = sut.simulateFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(view1?.renderedData, .none)
        XCTAssertEqual(view2?.renderedData, .none)
        
        let imageData1 = UIImage.make(with: .red).pngData()!
        loader.completeImageLoading(at: 0, data: imageData1)
        XCTAssertEqual(view1?.renderedData, imageData1)
        XCTAssertEqual(view2?.renderedData, .none)
        
        let imageData2 = UIImage.make(with: .blue).pngData()!
        loader.completeImageLoading(at: 1, data: imageData2)
        XCTAssertEqual(view1?.renderedData, imageData1)
        XCTAssertEqual(view2?.renderedData, imageData2)
    }
    
    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadedError() {
        let image1 = makeFeedImage()
        let image2 = makeFeedImage()

        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(at: 0, feed: [image1, image2])
        
        let view1 = sut.simulateFeedImageViewVisible(at: 0)
        let view2 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view1?.isShowingRetryAction, false)
        XCTAssertEqual(view2?.isShowingRetryAction, false)

        let imageData = UIImage.make(with: .red).pngData()!
        loader.completeImageLoading(at: 0, data: imageData)
        XCTAssertEqual(view1?.isShowingRetryAction, false)
        XCTAssertEqual(view2?.isShowingRetryAction, false)
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view1?.isShowingRetryAction, false)
        XCTAssertEqual(view2?.isShowingRetryAction, true)
    }
    
    func test_feedImageViewReturnButton_isVisibleOnInvalidImageData() {
        let feed = makeFeedImage()
        
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(at: 0, feed: [feed])
        
        let invalidImageData = Data("invalid data".utf8)
        let view = sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, false)
        
        loader.completeImageLoading(at: 0, data: invalidImageData)
        XCTAssertEqual(view?.isShowingRetryAction, true)
    }
    
    func test_feedImageViewRetryAction_retriesImageLoad() {
        let image1 = makeFeedImage(url: URL(string: "https://google.com")!)
        let image2 = makeFeedImage(url: URL(string: "https://test.com")!)
        
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(at: 0, feed: [image1, image2])
        
        let view1 = sut.simulateFeedImageViewVisible(at: 0)
        let view2 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image1.url, image2.url])
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image1.url, image2.url])
        
        view1?.simulateRetryAction()
        view2?.simulateRetryAction()
        
        XCTAssertEqual(loader.loadedImageURLs, [image1.url, image2.url, image1.url, image2.url])
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let image1 = makeFeedImage(url: URL(string: "https://google.com")!)
        let image2 = makeFeedImage(url: URL(string: "https://test.com")!)
        
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(at: 0, feed: [image1, image2])
        XCTAssertEqual(loader.loadedImageURLs, [])
        
        sut.simulateFeedImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image1.url])
        
        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image1.url, image2.url])
    }
    
    func test_feedImageView_cancelPreloadImageURLWhenNotVisible() {
        let image1 = makeFeedImage(url: URL(string: "https://google.com")!)
        let image2 = makeFeedImage(url: URL(string: "https://test.com")!)
        
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(at: 0, feed: [image1, image2])
        XCTAssertEqual(loader.loadedImageURLs, [])
        
        sut.simulateFeedImageViewNearVisible(at: 0)
        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image1.url, image2.url])
        
        sut.simulateFeedImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledLoadURLs, [image1.url])
        
        sut.simulateFeedImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledLoadURLs, [image1.url, image2.url])
    }
    
    // MARK: - Helpers
    private func makeSUT() -> (sut: FeedViewController, loader: FeedLoaderSpy) {
        let loader = FeedLoaderSpy()
        let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
        checkMemoryLeak(for: loader)
        checkMemoryLeak(for: sut)
        return (sut, loader)
    }
    
    private func makeFeedImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "https://test.com")!) -> FeedImage {
        return FeedImage(uuid: UUID(), description: description, location: location, url: url)
    }
    
    private func assertThat(sut: FeedViewController, rendering feeds: [FeedImage]) {
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), feeds.count)
        
        for (index, feed) in feeds.enumerated() {
            assertThat(cellDataAt: index, equalTo: feed, sut: sut)
        }
    }
    
    private func assertThat(cellDataAt index: Int, equalTo feed: FeedImage, sut: FeedViewController) {
        let view = sut.getFeedImageView(at: index) as? FeedImageCell
        let shouldDisplayLocation = feed.location != nil
        
        XCTAssertNotNil(view)
        XCTAssertEqual(view?.isShowingLocation, shouldDisplayLocation)
        XCTAssertEqual(view?.descriptionText, feed.description)
        XCTAssertEqual(view?.locationText, feed.location)
    }
    
    private class FeedLoaderSpy: FeedLoader, FeedImageDataLoader {
        
        // MARK: - FeedLoader
        
        private var feedRequests: [(Response) -> Void] = []
        
        var loadFeedCount: Int {
            return feedRequests.count
        }
                
        func load(completion: @escaping (Response) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(at index: Int, feed: [FeedImage] = []) {
            feedRequests[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            feedRequests[index](.failure(anyNSError()))
        }
        
        // MARK: - FeedImageDataLoader
        
        private class FeedDataLoaderTaskSpy: FeedImageDataLoaderTask {
            
            private let completion: () -> Void
            
            init(completion: @escaping () -> Void) {
                self.completion = completion
            }
            
            func cancel() {
                completion()
            }
        }
        
        private(set) var loadedImageURLs: [URL] = []
        private(set) var cancelledLoadURLs: [URL] = []
        private var imageLoadingRequest: [(Result<Data, Error>) -> Void] = []
        
        func loadImage(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> FeedImageDataLoaderTask {
            loadedImageURLs.append(url)
            imageLoadingRequest.append(completion)
            
            return FeedDataLoaderTaskSpy { [weak self] in
                self?.cancelledLoadURLs.append(url)
            }
        }
        
        func completeImageLoading(at index: Int, data: Data = Data()) {
            imageLoadingRequest[index](.success(data))
        }
        
        func completeImageLoadingWithError(at index: Int) {
            imageLoadingRequest[index](.failure(anyNSError()))
        }
    }
}

private extension UITableViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulateRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
}

private extension UIRefreshControl {
    func simulateRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension FeedViewController {
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return getFeedImageView(at: index) as? FeedImageCell
    }
    
    func simulateFeedImageViewNotVisible(at index: Int) {
        let view = simulateFeedImageViewVisible(at: index)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: index, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: feedImageSection)
    }
    
    func getFeedImageView(at index: Int) -> UITableViewCell? {
        let dataSource = tableView.dataSource
        let index = IndexPath(row: index, section: feedImageSection)
        return dataSource?.tableView(tableView, cellForRowAt: index)
    }
    
    func simulateFeedImageViewNearVisible(at index: Int) {
        let prefetchDataSource = tableView.prefetchDataSource
        let index = IndexPath(row: index, section: feedImageSection)
        prefetchDataSource?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageViewNotNearVisible(at index: Int) {
        let prefetchDataSource = tableView.prefetchDataSource
        let index = IndexPath(row: index, section: feedImageSection)
        prefetchDataSource?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    private var feedImageSection: Int {
        return 0
    }
}

private extension FeedImageCell {
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return feedImageContainer.isShimmering
    }
    
    var renderedData: Data? {
        return feedImageView.image?.pngData()
    }
    
    var isShowingRetryAction: Bool {
        return !retryButton.isHidden
    }
    
    func simulateRetryAction() {
        retryButton.simulateTap()
    }
}

private extension UIImage {
    static func make(with color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

private extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
