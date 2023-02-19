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
        
        sut.insert(feed, timestamp: timestamp) { error in
            if let expectedError = expectedError, error == nil {
                XCTFail("Expect to get error = \(expectedError), but got nil")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func expact(_ sut: FeedStore, retriveResult: RetriveCachedFeedResult) {
        let ext = expectation(description: "Wait for response")
        
        sut.retrive { result in
            switch (result, retriveResult) {
            case let (.found(retriveFeed, retriveTimestamp), .found(expectedFeed, expectedTimestamp)):
                XCTAssertEqual(retriveFeed, expectedFeed)
                XCTAssertEqual(retriveTimestamp, expectedTimestamp)
            case (.empty, .empty):
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
        
        sut.deleteCacheFeed { error in
            capturedError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        
        return capturedError
    }
    
    func assertThatRetrieveDeliversEmptyOnEmptyCash(sut: FeedStore) {
        expact(sut, retriveResult: .empty)
    }
    
    func assertThatRetrieveTwiceCallDeliversEmptyOnEmptyCash(sut: FeedStore) {
        expact(sut, retriveResult: .empty)
        expact(sut, retriveResult: .empty)
    }
    
    func assertThatRetrieveAfterInsertingToEmptyCashDeliversInsertedValues(sut: FeedStore) {
        let timestamp = Date()
        let feed = createImageFeed().localFeed
        
        insert(feed, timestamp: timestamp, sut: sut, expectedError: nil)
        
        expact(sut, retriveResult: .found(feed: feed, timestamp: timestamp))
    }
    
    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(sut: FeedStore) {
        let timestamp = Date()
        let feed = createImageFeed().localFeed
        
        insert(feed, timestamp: timestamp, sut: sut, expectedError: nil)
        
        expact(sut, retriveResult: .found(feed: feed, timestamp: timestamp))
        expact(sut, retriveResult: .found(feed: feed, timestamp: timestamp))
    }
    
    func assertThatInsertDeliversNewInsertedValueOnNonEmptyCache(sut: FeedStore) {
        let feed = [createImageFeed().localFeed[1]]
        let timestamp = Date()
        
        insert([createImageFeed().localFeed[.zero]], timestamp: Date(), sut: sut, expectedError: nil)
        insert(feed, timestamp: timestamp, sut: sut, expectedError: nil)
        
        expact(sut, retriveResult: .found(feed: feed, timestamp: timestamp))
    }
    
    func assertThatDeleteDeleteOnEmptyCacheHasNoSideEffects(sut: FeedStore) {
        let deletingError = delete(from: sut)
        XCTAssertNil(deletingError, "Expect no errors on deletion empty cache")
        
        expact(sut, retriveResult: .empty)
    }
    
    func assertThatDeleteDeletePrivioslyInsetredValues(sut: FeedStore) {
        insert(createImageFeed().localFeed, timestamp: Date(), sut: sut, expectedError: nil)
        
        let deletingError = delete(from: sut)
        XCTAssertNil(deletingError, "Expect no errors on deletion cache")
        
        expact(sut, retriveResult: .empty)
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
