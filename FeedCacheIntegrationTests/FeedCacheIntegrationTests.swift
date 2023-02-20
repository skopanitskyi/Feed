//
//  FeedCacheIntegrationTests.swift
//  FeedCacheIntegrationTests
//
//  Created by Сергей Копаницкий on 20.02.2023.
//

import XCTest
import Feed

class FeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        deleteStoreFile()
    }
    
    override func tearDown() {
        super.tearDown()
        deleteStoreFile()
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        expext(sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let items = createImageFeed().items
        
        expect(sutToPerformSave, toSave: items, resultError: nil)
        
        expext(sutToPerformLoad, toLoad: items)
    }
    
    func test_load_deliversLatestSavedItemsOnASeparateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstFeed = createImageFeed().items[0]
        let secondFeed = createImageFeed().items[1]
        
        expect(sutToPerformFirstSave, toSave: [firstFeed], resultError: nil)
        expect(sutToPerformLastSave, toSave: [secondFeed], resultError: nil)
        expext(sutToPerformLoad, toLoad: [secondFeed])
    }
    
    // MARK: - Private methods
    
    private func makeSUT() -> LocalFeedLoader {
        let storeURL = storeURL()
        let bunlde = Bundle(for: ManagedFeedCache.self)
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: bunlde)
        let loader = LocalFeedLoader(store: store, currnentDate: Date.init)
        checkMemoryLeak(for: store)
        checkMemoryLeak(for: loader)
        return loader
    }
    
    private func storeURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func deleteStoreFile() {
        try? FileManager.default.removeItem(at: storeURL())
    }
    
    private func expext(_ sut: LocalFeedLoader, toLoad feed: [FeedImage]) {
        let expectation = expectation(description: "Wait for response")
        
        sut.load { result in
            switch result {
            case .success(let items):
                XCTAssertEqual(feed, items)
            case .failure(let error):
                XCTFail("Expect to receive no items, but got error = \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    private func expect(_ sut: LocalFeedLoader, toSave items: [FeedImage], resultError: Error?) {
        let saveExpectation = expectation(description: "Wait for response")
        sut.save(items) { error in
            switch (error, resultError) {
            case (nil, nil):
                break
            case (let error, nil):
                XCTFail("Expect no errors on saving items, but got \(error!)")
            case (nil, let error):
                XCTFail("Expect \(error!) on saving items, but got no errors")
            default:
                break
            }
            saveExpectation.fulfill()
        }
        
        wait(for: [saveExpectation], timeout: 1)
    }
}
