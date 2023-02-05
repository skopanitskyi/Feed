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
    
    func test_load_deliversCachedImagesOnLessThenSevenDaysOldCache() {
        let currentDate = Date()
        let lessThenSevenDaysTimestamp = currentDate.adding(days: -7).adding(second: 1)
        let (sut, store) = makeSUT { return currentDate }
        let feed = createImageFeed()
        
        expact(sut, with: .success(feed.items)) {
            store.completeRetriveCache(feed.localFeed, timestamp: lessThenSevenDaysTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnExpiredCache() {
        let currentDate = Date()
        let sevenDaysTimestamp = currentDate.adding(days: -7)
        let (sut, store) = makeSUT { return currentDate }
        let feed = createImageFeed()
        
        expact(sut, with: .success([])) {
            store.completeRetriveCache(feed.localFeed, timestamp: sevenDaysTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnMoreThenSevenDaysExpiredCache() {
        let currentDate = Date()
        let moreThenSevenDaysTimestamp = currentDate.adding(days: -10)
        let (sut, store) = makeSUT { return currentDate }
        let feed = createImageFeed()
        
        expact(sut, with: .success([])) {
            store.completeRetriveCache(feed.localFeed, timestamp: moreThenSevenDaysTimestamp)
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
    
    func test_load_hasNoSideEffectsOnLessThenSevenDaysOldTimestamp() {
        let currentDate = Date()
        let lessThenSevenDaysTimestamp = currentDate.adding(days: -7).adding(second: 1)
        let (sut, store) = makeSUT { return currentDate }
        let feed = createImageFeed()
        
        sut.load { _ in }
        
        store.completeRetriveCache(feed.localFeed, timestamp: lessThenSevenDaysTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrive])
    }
    
    func test_load_hasNoSideEffectOnSevenDaysOldCache() {
        let currentDate = Date()
        let sevenDaysTimestamp = currentDate.adding(days: -7)
        let (sut, store) = makeSUT { return currentDate }
        let feed = createImageFeed()
        
        sut.load { _ in }
        
        store.completeRetriveCache(feed.localFeed, timestamp: sevenDaysTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrive])
    }
    
    func test_load_hasNoSideEffectOnMoreThenSevenDaysOldCache() {
        let currentDate = Date()
        let moreThenSevenDaysTimestamp = currentDate.adding(days: -7).adding(second: -1)
        let (sut, store) = makeSUT { return currentDate }
        let feed = createImageFeed()
        
        sut.load { _ in }
        
        store.completeRetriveCache(feed.localFeed, timestamp: moreThenSevenDaysTimestamp)

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
