//
//  XCTestCase + FeedStoreSpecs.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 11.02.2023.
//

import Feed
import XCTest

extension FeedStoreSpecs where Self: XCTestCase {
    func insert(_ feed: [LocalFeedImage], timestamp: Date, sut: FeedStore, expectedError: NSError?) {
        let exp = expectation(description: "Wait for completion response")
        
        sut.insert(feed, timestamp: timestamp) { result in
            switch (result, expectedError) {
            case (.success, let .some(error)):
                XCTFail("Expect to get error = \(error), but got success")
            case (.failure(_), .some(_)):
                break
            case (.failure(let error), .none):
                XCTFail("Expect to get no error, but got \(error)")
            default:
                break
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func expact(_ sut: FeedStore, retriveResult: FeedStore.RetriveResult) {
        let ext = expectation(description: "Wait for response")
        
        sut.retrive { result in
            switch (result, retriveResult) {
            case let (.success(.some(retriveCache)), .success(.some(expextedCache))):
                XCTAssertEqual(retriveCache.feed, expextedCache.feed)
                XCTAssertEqual(retriveCache.timestamp, expextedCache.timestamp)
            case (.success(.none), .success(.none)):
                break
            case (.failure, .failure):
                break
            default:
                XCTFail("Expect to get \(retriveResult), but got \(result)")
            }
            ext.fulfill()
        }
        
        wait(for: [ext], timeout: 1)
    }
    
    @discardableResult
    func delete(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for completion")
        var capturedError: Error?
        
        sut.deleteCacheFeed { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                capturedError = error
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        
        return capturedError
    }
    
    func assertThatRetrieveDeliversEmptyOnEmptyCash(sut: FeedStore) {
        expact(sut, retriveResult: .success(.none))
    }
    
    func assertThatRetrieveTwiceCallDeliversEmptyOnEmptyCash(sut: FeedStore) {
        expact(sut, retriveResult: .success(.none))
        expact(sut, retriveResult: .success(.none))
    }
    
    func assertThatRetrieveAfterInsertingToEmptyCashDeliversInsertedValues(sut: FeedStore) {
        let timestamp = Date()
        let feed = createImageFeed().localFeed
        
        insert(feed, timestamp: timestamp, sut: sut, expectedError: nil)
        
        expact(sut, retriveResult: .success(.init(feed: feed, timestamp: timestamp)))
    }
    
    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(sut: FeedStore) {
        let timestamp = Date()
        let feed = createImageFeed().localFeed
        
        insert(feed, timestamp: timestamp, sut: sut, expectedError: nil)
        
        expact(sut, retriveResult: .success(.init(feed: feed, timestamp: timestamp)))
        expact(sut, retriveResult: .success(.init(feed: feed, timestamp: timestamp)))
    }
    
    func assertThatInsertDeliversNewInsertedValueOnNonEmptyCache(sut: FeedStore) {
        let feed = [createImageFeed().localFeed[1]]
        let timestamp = Date()
        
        insert([createImageFeed().localFeed[.zero]], timestamp: Date(), sut: sut, expectedError: nil)
        insert(feed, timestamp: timestamp, sut: sut, expectedError: nil)
        
        expact(sut, retriveResult: .success(.init(feed: feed, timestamp: timestamp)))
    }
    
    func assertThatDeleteDeleteOnEmptyCacheHasNoSideEffects(sut: FeedStore) {
        let deletingError = delete(from: sut)
        XCTAssertNil(deletingError, "Expect no errors on deletion empty cache")
        
        expact(sut, retriveResult: .success(.none))
    }
    
    func assertThatDeleteDeletePrivioslyInsetredValues(sut: FeedStore) {
        insert(createImageFeed().localFeed, timestamp: Date(), sut: sut, expectedError: nil)
        
        let deletingError = delete(from: sut)
        XCTAssertNil(deletingError, "Expect no errors on deletion cache")
        
        expact(sut, retriveResult: .success(.none))
    }
    
    func assertThatStoreSideEffectsRunSerially(sut: FeedStore) {
        var completedOperationsInOrder: [XCTestExpectation] = []
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(createImageFeed().localFeed, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCacheFeed { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.retrive { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5)
        
        XCTAssertEqual([op1, op2, op3], completedOperationsInOrder)
    }
}
