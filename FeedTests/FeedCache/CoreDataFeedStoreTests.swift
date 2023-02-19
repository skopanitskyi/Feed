//
//  CoreDataFeedStoreTests.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 12.02.2023.
//

import XCTest
import Feed

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    
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
    
    func test_insert_deliversNewInsertedValueOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatInsertDeliversNewInsertedValueOnNonEmptyCache(sut: sut)
    }
    
    func test_delete_deleteOnEmptyCacheHasNoSideEffects() {
        let sut = makeSUT()
        
        assertThatDeleteDeleteOnEmptyCacheHasNoSideEffects(sut: sut)
    }
    
    func test_delete_deletePrivioslyInsetredValues() {
        let sut = makeSUT()
        
        assertThatDeleteDeletePrivioslyInsetredValues(sut: sut)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        
        assertThatStoreSideEffectsRunSerially(sut: sut)
    }
    
    // MARK: - Private methods
    private func makeSUT() -> FeedStore {
        let bundle = Bundle(for: ManagedFeedCache.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: bundle)
        checkMemoryLeak(for: sut)
        return sut
    }
}
