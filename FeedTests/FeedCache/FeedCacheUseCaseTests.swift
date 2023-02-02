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
    
    public func save(items: [FeedItem]) {
        store.deleteCacheFeed { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                
            } else {
                self.store.insert(items: items, timestamp: self.currnentDate())
            }
        }
    }
    
}

public class FeedStore {
    public typealias DeletionCompletion = ((Error?) -> Void)
    
    private(set) var receivedMessages: [ReceivedMessages] = []
    
    private var capturedDeletionCompletions: [DeletionCompletion] = []
    
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
    
    public func insert(items: [FeedItem], timestamp: Date) {
        receivedMessages.append(.insert(items: items, timestamp: timestamp))
    }
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
    
    private func makeSUT(currnentDate: @escaping () -> Date = Date.init) -> (LocalFeedLoader, FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currnentDate: currnentDate)
        checkMemoryLeak(for: sut)
        checkMemoryLeak(for: store)
        return (sut, store)
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
}
