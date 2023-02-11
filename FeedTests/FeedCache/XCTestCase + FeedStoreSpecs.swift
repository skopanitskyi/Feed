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
}
