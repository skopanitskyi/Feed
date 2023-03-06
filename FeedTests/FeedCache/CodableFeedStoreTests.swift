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
        
        assertThatRetrieveDeliversEmptyOnEmptyCash(sut: sut)
    }
    
    func test_retrieve_twiceCallDeliversEmptyOnEmptyCash() {
        let sut = makeSUT()
        
        assertThatRetrieveTwiceCallDeliversEmptyOnEmptyCash(sut: sut)
    }
    
    func test_retrieveAfterInsertingToEmptyCash_deliversInsertedValues() {
        let sut = makeSUT()
        
        assertThatRetrieveAfterInsertingToEmptyCashDeliversInsertedValues(sut: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(sut: sut)
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testTypeSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        try? "test data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        assertThatRetriveDeliversFailureOnRetrievalError(sut: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testTypeSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        try? "test data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        assertThatRetriveHasNoSideEffectsOnFailure(sut: sut)
    }
    
    func test_insert_deliversNewInsertedValueOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatInsertDeliversNewInsertedValueOnNonEmptyCache(sut: sut)
    }
    
    func test_insert_deliversErrorOnInsertionError()  {
        let invalidStoreURL = URL(string: "://invalid-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        assertThatInsertDeliversErrorOnInsertionError(sut: sut)
    }
    
    func test_insert_failureInsertHasNoSideEffects()  {
        let invalidStoreURL = URL(string: "://invalid-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        assertThatInsertFailureHasNoSideEffects(sut: sut)
    }
    
    func test_delete_deleteOnEmptyCacheHasNoSideEffects() {
        let sut = makeSUT()
        
        assertThatDeleteDeleteOnEmptyCacheHasNoSideEffects(sut: sut)
    }
    
    func test_delete_deletePrivioslyInsetredValues() {
        let sut = makeSUT()
        
        assertThatDeleteDeletePrivioslyInsetredValues(sut: sut)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noAccessDirectoryURL = cachesDirectory()
        let sut = makeSUT(storeURL: noAccessDirectoryURL)
        
        assertThatDeleteDeliversErrorOnDeletionError(sut: sut)
    }
    
    func test_delete_failureDeletingHasNoSideEffects() {
        let noAccessDirectoryURL = cachesDirectory()
        let sut = makeSUT(storeURL: noAccessDirectoryURL)
        
        assertThatDeleteFailureDeletingHasNoSideEffects(sut: sut)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        
        assertThatStoreSideEffectsRunSerially(sut: sut)
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
        return FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
    }
}
