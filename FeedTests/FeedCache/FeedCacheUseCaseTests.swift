//
//  FeedCacheUseCaseTests.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 02.02.2023.
//

import XCTest
import Feed

class FeedCacheUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheAfterCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let feed = createImageFeed().items
        sut.save(feed)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_doesNotRequestCacheInsertOnDeletionError() {
        let (sut, store) = makeSUT()
        let feed = createImageFeed().items
        sut.save(feed)
        store.completeDeletion(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT { timestamp }
        let feed = createImageFeed()
        sut.save(feed.items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed , .insert(feed: feed.localFeed, timestamp: timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let deletionError = anyNSError()
        let (sut, store) = makeSUT()
        
        expect(sut, expectedError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsOnInsertionError() {
        let insertionError = anyNSError()
        let (sut, store) = makeSUT()
        
        expect(sut, expectedError: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_successfullDeletingAndInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, expectedError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    func test_save_doesNotDeliversSaveErrorAfterSUTHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currnentDate: Date.init)
        
        var storedResults: [LocalFeedLoader.SaveResult] = []
        
        sut?.save(createImageFeed().items) { error in
            storedResults.append(error)
        }
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(storedResults.isEmpty)
    }
    
    func test_save_doesNotDeliversInsertionErrorAfterSUTHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currnentDate: Date.init)
        
        var storedResults: [LocalFeedLoader.SaveResult] = []
        
        sut?.save(createImageFeed().items) { error in
            storedResults.append(error)
        }
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(storedResults.isEmpty)
    }
    
    private func makeSUT(currnentDate: @escaping () -> Date = Date.init) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currnentDate: currnentDate)
        checkMemoryLeak(for: sut)
        checkMemoryLeak(for: store)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, expectedError: NSError?, when action: (() -> Void)? = nil) {
        let items = createImageFeed().items
        let exp = expectation(description: "wait for completion")
        var receivedError: NSError?
        
        sut.save(items) { error in
            receivedError = error as NSError?
            exp.fulfill()
        }
        
        action?()
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(receivedError, expectedError)
    }
    
    private func createImageFeed() -> (items: [FeedImage], localFeed: [LocalFeedImage]) {
        let feed1 = FeedImage(uuid: UUID(), description: "test", location: "location 1", url: makeURL())
        let feed2 = FeedImage(uuid: UUID(), description: "test 2", location: "location 2", url: makeURL())
        let feed = [feed1, feed2]
        let localFeed = feed.map {
            return LocalFeedImage(
                uuid: $0.uuid,
                description: $0.description,
                location: $0.location,
                url: $0.url)
        }
        
        return (items: feed, localFeed: localFeed)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1000, userInfo: nil)
    }
    
    private func makeURL() -> URL {
        return URL(string: "https://google.com")!
    }
}
