//
//  FeedCacheUseCaseTests.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 02.02.2023.
//

import XCTest
import Feed

public class LocalFeedLoader {
    private let store: FeedStore
    private let currnentDate: () -> Date
    
    public init(store: FeedStore, currnentDate: @escaping () -> Date) {
        self.store = store
        self.currnentDate = currnentDate
    }
    
    public func save(items: [FeedItem], completion: ((Error?) -> Void)? = nil) {
        store.deleteCacheFeed { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                completion?(error)
            } else {
                self.store.insert(items: items, timestamp: self.currnentDate()) { error in
                    completion?(error)
                }
            }
        }
    }
}

public protocol FeedStore {
    typealias DeletionCompletion = ((Error?) -> Void)
    typealias InsertionCompletion = ((Error?) -> Void)
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion)
    func insert(items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}

class FeedCacheUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheAfterCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = createFeedItems()
        sut.save(items: items)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_doesNotRequestCacheInsertOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = createFeedItems()
        sut.save(items: items)
        store.completeDeletion(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT { timestamp }
        let items = createFeedItems()
        sut.save(items: items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed , .insert(items: items, timestamp: timestamp)])
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
    
    private func makeSUT(currnentDate: @escaping () -> Date = Date.init) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currnentDate: currnentDate)
        checkMemoryLeak(for: sut)
        checkMemoryLeak(for: store)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, expectedError: NSError?, when action: (() -> Void)? = nil) {
        let items = createFeedItems()
        let exp = expectation(description: "wait for completion")
        var receivedError: NSError?
        
        sut.save(items: items) { error in
            receivedError = error as NSError?
            exp.fulfill()
        }
        
        action?()
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(receivedError, expectedError)

    }
    
    private func createFeedItems() -> [FeedItem] {
        return [
            .init(uuid: UUID(), description: "test", location: "location 1", imageURL: makeURL()),
            .init(uuid: UUID(), description: "test 2", location: "location 2", imageURL: makeURL())
        ]
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1000, userInfo: nil)
    }
    
    private func makeURL() -> URL {
        return URL(string: "https://google.com")!
    }
    
    private class FeedStoreSpy: FeedStore {
        
        private(set) var receivedMessages: [ReceivedMessages] = []
        
        private var capturedDeletionCompletions: [DeletionCompletion] = []
        private var capturedInsertionCompletions: [InsertionCompletion] = []
        
        public enum ReceivedMessages: Equatable {
            case deleteCacheFeed
            case insert(items: [FeedItem], timestamp: Date)
        }
        
        public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
            receivedMessages.append(.deleteCacheFeed)
            capturedDeletionCompletions.append(completion)
        }
        
        public func completeDeletion(with error: Error, at index: Int = .zero) {
            capturedDeletionCompletions[index](error)
        }
        
        public func completeDeletionSuccessfully(at index: Int = .zero) {
            capturedDeletionCompletions[index](nil)
        }
        
        public func insert(items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
            receivedMessages.append(.insert(items: items, timestamp: timestamp))
            capturedInsertionCompletions.append(completion)
        }
        
        public func completeInsertion(with error: Error, at index: Int = .zero) {
            capturedInsertionCompletions[index](error)
        }
        
        public func completeInsertionSuccessfully(at index: Int = .zero) {
            capturedInsertionCompletions[index](nil)
        }
    }
}
