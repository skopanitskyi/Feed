//
//  LoadFeedFromCacheUseCaseTests.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 04.02.2023.
//

import XCTest
import Feed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheAfterCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrivel() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrive])
    }
    
    func test_load_failsOnRetrivalError() {
        let (sut, store) = makeSUT()
        let expextedError = anyNSError()
        
        expact(sut, with: .failure(expextedError)) {
            store.completeRetrival(with: expextedError)
        }
    }
    
    func test_load_retriveNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expact(sut, with: .success([])) {
            store.completeRetriveEmptyCache()
        }
    }
    
    func test_load_deliversCachedImagesOnNonExpiredCache() {
        let currentDate = Date()
        let nonExpitedTimestamp = currentDate.minusFeedCacheMaxAge().adding(second: 1)
        let (sut, store) = makeSUT { return currentDate }
        let feed = createImageFeed()
        
        expact(sut, with: .success(feed.items)) {
            store.completeRetriveCache(feed.localFeed, timestamp: nonExpitedTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnExpiredCache() {
        let currentDate = Date()
        let expiredTimestamp = currentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT { return currentDate }
        let feed = createImageFeed()
        
        expact(sut, with: .success([])) {
            store.completeRetriveCache(feed.localFeed, timestamp: expiredTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnMoreThenSevenDaysExpiredCache() {
        let currentDate = Date()
        let expiredTimestamp = currentDate.minusFeedCacheMaxAge().adding(second: -1)
        let (sut, store) = makeSUT { return currentDate }
        let feed = createImageFeed()
        
        expact(sut, with: .success([])) {
            store.completeRetriveCache(feed.localFeed, timestamp: expiredTimestamp)
        }
    }
    
    func test_load_hasNoSideEffectOnRetrivelError() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        store.completeRetrival(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrive])
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        store.completeRetriveEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrive])
    }
    
    func test_load_hasNoSideEffectsOnNonExpiredTimestamp() {
        let currentDate = Date()
        let nonExpiredTimestamp = currentDate.minusFeedCacheMaxAge().adding(second: 1)
        let (sut, store) = makeSUT { return currentDate }
        let feed = createImageFeed()
        
        sut.load { _ in }
        
        store.completeRetriveCache(feed.localFeed, timestamp: nonExpiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrive])
    }
    
    func test_load_hasNoSideEffectOnExpiredCache() {
        let currentDate = Date()
        let expiredTimestamp = currentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT { return currentDate }
        let feed = createImageFeed()
        
        sut.load { _ in }
        
        store.completeRetriveCache(feed.localFeed, timestamp: expiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrive])
    }
    
    func test_load_hasNoSideEffectOnMoreThenCacheMaxAgeCache() {
        let currentDate = Date()
        let expiredTimestamp = currentDate.minusFeedCacheMaxAge().adding(second: -1)
        let (sut, store) = makeSUT { return currentDate }
        let feed = createImageFeed()
        
        sut.load { _ in }
        
        store.completeRetriveCache(feed.localFeed, timestamp: expiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrive])
    }
    
    func test_load_doesNotDeliversResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currnentDate: Date.init)
        var retriveResult: LocalFeedLoader.RetriveResult?
        
        sut?.load { result in
            retriveResult = result
        }
        
        sut = nil
        store.completeRetriveEmptyCache()
        
        XCTAssertNil(retriveResult)
    }
    
    // MARK: - Private methods
    
    private func makeSUT(currnentDate: @escaping () -> Date = Date.init) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currnentDate: currnentDate)
        checkMemoryLeak(for: sut)
        checkMemoryLeak(for: store)
        return (sut, store)
    }
    
    private func expact(_ sut: LocalFeedLoader, with expectedResult: LocalFeedLoader.RetriveResult, action: (() -> Void)) {
        let ext = expectation(description: "wait for closure call")
        
        sut.load { result in
            switch (result, expectedResult) {
            case (.success(let resultFeed), .success(let expectedFeed)):
                XCTAssertEqual(resultFeed, expectedFeed)
            case (.failure(let resultError as NSError?), .failure(let expectedError as NSError?)):
                XCTAssertEqual(resultError?.code, expectedError?.code)
            default:
                XCTFail("Expect to get result = \(expectedResult), but got = \(result)")
            }
            
            ext.fulfill()
        }
        
        action()
        
        wait(for: [ext], timeout: 1)
    }
}
