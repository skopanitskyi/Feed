//
//  CodableFeedStoreTests.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 09.02.2023.
//

import XCTest
import Feed

class CodableFeedStoreTests: XCTestCase, FailableFeedStore {
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        setupEmptyStoreState()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCash() {
        let sut = makeSUT()
        
        expact(sut, retriveResult: .empty)
    }
    
    func test_retrieve_twiceCallDeliversEmptyOnEmptyCash() {
        let sut = makeSUT()
        
        expact(sut, retriveResult: .empty)
        expact(sut, retriveResult: .empty)
    }
    
    func test_retrieveAfterInsertingToEmptyCash_deliversInsertedValues() {
        let sut = makeSUT()
        let timestamp = Date()
        let feed = createImageFeed().localFeed
        
        insert(feed, timestamp: timestamp, sut: sut, expectedError: nil)
        
        expact(sut, retriveResult: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let timestamp = Date()
        let feed = createImageFeed().localFeed
        
        insert(feed, timestamp: timestamp, sut: sut, expectedError: nil)
        
        expact(sut, retriveResult: .found(feed: feed, timestamp: timestamp))
        expact(sut, retriveResult: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testTypeSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        try? "test data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expact(sut, retriveResult: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testTypeSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        try? "test data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expact(sut, retriveResult: .failure(anyNSError()))
        expact(sut, retriveResult: .failure(anyNSError()))
    }
    
    func test_insert_deliversNewInsertedValueOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = [createImageFeed().localFeed[1]]
        let timestamp = Date()
        
        insert([createImageFeed().localFeed[.zero]], timestamp: Date(), sut: sut, expectedError: nil)
        insert(feed, timestamp: timestamp, sut: sut, expectedError: nil)
        
        expact(sut, retriveResult: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_insert_deliversErrorOnInsertionError()  {
        let invalidStoreURL = URL(string: "://invalid-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        insert(createImageFeed().localFeed, timestamp: Date(), sut: sut, expectedError: anyNSError())
    }
    
    func test_insert_failureInsertHasNoSideEffects()  {
        let invalidStoreURL = URL(string: "://invalid-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        insert(createImageFeed().localFeed, timestamp: Date(), sut: sut, expectedError: anyNSError())
        
        expact(sut, retriveResult: .empty)
    }
    
    func test_delete_deleteOnEmptyCacheHasNoSideEffects() {
        let sut = makeSUT()

        let deletingError = delete(from: sut)
        XCTAssertNil(deletingError, "Expect no errors on deletion empty cache")
        
        expact(sut, retriveResult: .empty)
    }
    
    func test_delete_deletePrivioslyInsetredValues() {
        let sut = makeSUT()

        insert(createImageFeed().localFeed, timestamp: Date(), sut: sut, expectedError: nil)
        
        let deletingError = delete(from: sut)
        XCTAssertNil(deletingError, "Expect no errors on deletion cache")
        
        expact(sut, retriveResult: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noAccessDirectoryURL = cachesDirectory()
        let sut = makeSUT(storeURL: noAccessDirectoryURL)
        
        let deletionError = delete(from: sut)
        XCTAssertNotNil(deletionError, "Expect to get error on deletion invalid data url, but got nil")
    }
    
    func test_delete_failureDeletingHasNoSideEffects() {
        let noAccessDirectoryURL = cachesDirectory()
        let sut = makeSUT(storeURL: noAccessDirectoryURL)
        
        delete(from: sut)
        
        expact(sut, retriveResult: .empty)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
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
    
    // MARK: - Private methods
    private func makeSUT(storeURL: URL? = nil) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testTypeSpecificStoreURL())
        checkMemoryLeak(for: sut)
        return sut
    }

    private func setupEmptyStoreState() {
        try? FileManager.default.removeItem(at: testTypeSpecificStoreURL())
    }
    
    private func testTypeSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
