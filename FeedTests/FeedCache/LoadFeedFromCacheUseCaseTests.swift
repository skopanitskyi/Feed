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
        
        sut.retrive()
        
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
        let feed = makeFeed()
        
        expact(sut, with: .success([feed.feed])) {
            store.completeRetriveCache([feed.localFeed], timestamp: lessThenSevenDaysTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnExpiredCache() {
        let currentDate = Date()
        let sevenDaysTimestamp = currentDate.adding(days: -7)
        let (sut, store) = makeSUT { return currentDate }
        let feed = makeFeed()
        
        expact(sut, with: .success([])) {
            store.completeRetriveCache([feed.localFeed], timestamp: sevenDaysTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnMoreThenSevenDaysExpiredCache() {
        let currentDate = Date()
        let moreThenSevenDaysTimestamp = currentDate.adding(days: -10)
        let (sut, store) = makeSUT { return currentDate }
        let feed = makeFeed()
        
        expact(sut, with: .success([])) {
            store.completeRetriveCache([feed.localFeed], timestamp: moreThenSevenDaysTimestamp)
        }
    }
    
    // MARK: - Private methods
    
    private func makeSUT(currnentDate: @escaping () -> Date = Date.init) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currnentDate: currnentDate)
        checkMemoryLeak(for: sut)
        checkMemoryLeak(for: store)
        return (sut, store)
    }
    
    private func makeFeed() -> (feed: FeedImage, localFeed: LocalFeedImage) {
        let feed = FeedImage(uuid: UUID(), description: "test", location: "111", url: makeURL())
        let localFeed = LocalFeedImage(uuid: feed.uuid, description: feed.description, location: feed.location, url: feed.url)
        return (feed, localFeed)
    }
    
    private func expact(_ sut: LocalFeedLoader, with expectedResult: LocalFeedLoader.RetriveResult, action: (() -> Void)) {
        let ext = expectation(description: "wait for closure call")
        
        sut.retrive { result in
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
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1000, userInfo: nil)
    }
    
    private func makeURL() -> URL {
        return URL(string: "https://google.com")!
    }
}

private extension Date {
    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(second: Int) -> Date {
        return Calendar.current.date(byAdding: .second, value: second, to: self)!
    }
}
