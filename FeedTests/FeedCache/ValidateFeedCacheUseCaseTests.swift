//
//  ValidateFeedCacheUseCaseTests.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 05.02.2023.
//

import XCTest
import Feed

class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheAfterCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheFeedOnRetrivelError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        
        store.completeRetrival(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrive, .deleteCacheFeed])
    }
    
    func test_validateCache_doesNotDeleteOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        
        store.completeRetriveEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrive])
    }
    
    func test_validateCache_doesNotDeleteCacheOnNonExpiredTimestamp() {
        let currentDate = Date()
        let nonExpiredTimestamp = currentDate.minusFeedCacheMaxAge().adding(second: 1)
        let (sut, store) = makeSUT { return currentDate }
        let feed = createImageFeed()
        
        sut.validateCache()
        
        store.completeRetriveCache(feed.localFeed, timestamp: nonExpiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrive])
    }
    
    func test_validateCache_deletesOnExpiredCache() {
        let currentDate = Date()
        let expiredTimestamp = currentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT { return currentDate }
        let feed = createImageFeed()
        
        sut.validateCache()
        
        store.completeRetriveCache(feed.localFeed, timestamp: expiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrive, .deleteCacheFeed])
    }
    
    func test_validateCache_deletesOnMoreThenMaxCacheAgeTimestamp() {
        let currentDate = Date()
        let expiredTimestamp = currentDate.minusFeedCacheMaxAge().adding(second: -1)
        let (sut, store) = makeSUT { return currentDate }
        let feed = createImageFeed()
        
        sut.validateCache()
        
        store.completeRetriveCache(feed.localFeed, timestamp: expiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrive, .deleteCacheFeed])
    }
    
    func test_validateCache_doesNotDeliversResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currnentDate: Date.init)
        
        sut?.validateCache()
        sut = nil
        
        store.completeRetrival(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrive])
    }
    
    // MARK: - Private methods
    
    private func makeSUT(currnentDate: @escaping () -> Date = Date.init) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currnentDate: currnentDate)
        checkMemoryLeak(for: sut)
        checkMemoryLeak(for: store)
        return (sut, store)
    }
}
