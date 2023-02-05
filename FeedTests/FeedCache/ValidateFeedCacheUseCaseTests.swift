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
    
    func test_validateCache_doesNotDeleteLessThenSevenDaysOldCache() {
        let currentDate = Date()
        let lessThenSevenDaysTimestamp = currentDate.adding(days: -7).adding(second: 1)
        let (sut, store) = makeSUT { return currentDate }
        let feed = createImageFeed()
        
        sut.validateCache()
        
        store.completeRetriveCache(feed.localFeed, timestamp: lessThenSevenDaysTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrive])
    }
    
    func test_validateCache_deletesOnSevenDaysOldCache() {
        let currentDate = Date()
        let sevenDaysTimestamp = currentDate.adding(days: -7)
        let (sut, store) = makeSUT { return currentDate }
        let feed = createImageFeed()
        
        sut.validateCache()
        
        store.completeRetriveCache(feed.localFeed, timestamp: sevenDaysTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrive, .deleteCacheFeed])
    }
    
    func test_validateCache_deletesOnMoreThenSevenDaysOldCache() {
        let currentDate = Date()
        let moreThenSevenDaysTimestamp = currentDate.adding(days: -7).adding(second: -1)
        let (sut, store) = makeSUT { return currentDate }
        let feed = createImageFeed()
        
        sut.validateCache()
        
        store.completeRetriveCache(feed.localFeed, timestamp: moreThenSevenDaysTimestamp)

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
