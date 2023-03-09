//
//  FeedViewControllerTests.swift
//  FeediOSTests
//
//  Created by Сергей Копаницкий on 09.03.2023.
//

import XCTest
import UIKit
import Feed

final class FeedLoadrViewController: UITableViewController {
    
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadFeed), for: .valueChanged)
        loadFeed()
    }
    
    @objc
    private func loadFeed() {
        refreshControl?.beginRefreshing()
        
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

class FeedViewControllerTests: XCTestCase {
    
    func test_loadFeedActions_requestLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCount, 0)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCount, 1)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCount, 2)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCount, 3)
    }
    
    func test_loadingIndicatorVisible_whileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator)

        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator)

        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: FeedLoadrViewController, loader: FeedLoaderSpy) {
        let loader = FeedLoaderSpy()
        let sut = FeedLoadrViewController(loader: loader)
        checkMemoryLeak(for: loader)
        checkMemoryLeak(for: sut)
        return (sut, loader)
    }
    
    private class FeedLoaderSpy: FeedLoader {
        private var capturedResponses: [(Response) -> Void] = []
        
        var loadCount: Int {
            return capturedResponses.count
        }
                
        func load(completion: @escaping (Response) -> Void) {
            capturedResponses.append(completion)
        }
        
        func completeFeedLoading(at index: Int) {
            capturedResponses[index](.success([]))
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
