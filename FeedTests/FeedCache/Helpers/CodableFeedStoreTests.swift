//
//  CodableFeedStoreTests.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 09.02.2023.
//

import XCTest
import Feed

final class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var toLocal: [LocalFeedImage] {
            return feed.map { .init(uuid: $0.uuid, description: $0.description, location: $0.location, url: $0.url) }
        }
    }
    
    public struct CodableFeedImage: Codable {
        public let uuid: UUID
        public let description: String?
        public let location: String?
        public let url: URL
        
        init(_ feed: LocalFeedImage) {
            uuid = feed.uuid
            description = feed.description
            location = feed.location
            url = feed.url
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping FeedStore.RetriveCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: decoded.toLocal, timestamp: decoded.timestamp))
        } catch {
            completion(.failure(error))
        }
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        
        do {
            let encoded = try encoder.encode(cache)
            try encoded.write(to: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}

class CodableFeedStoreTests: XCTestCase {
    
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
        let exp = expectation(description: "Wait for completion response")
        
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expect to get empty result, but got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_retrieve_twiceCallDeliversEmptyOnEmptyCash() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion response")
        let timestamp = Date()
        let feed = createImageFeed().localFeed
        
        sut.insert(feed, timestamp: timestamp) { error in
            XCTAssertNil(error)
            
            sut.retrieve { result in
                switch result {
                case let .found(cacedFeed, cachedTimestamp):
                    XCTAssertEqual(timestamp, cachedTimestamp)
                    XCTAssertEqual(feed, cacedFeed)
                default:
                    XCTFail("Expect to get inserted feed, but got \(result) instead")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_retrieveAfterInsertingToEmptyCash_deliversInsertedValues() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion response")
        
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expect to get empty result, but got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Private methods
    private func makeSUT() -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: testTypeSpecificStoreURL())
        checkMemoryLeak(for: sut)
        return sut
    }
    
    private func setupEmptyStoreState() {
        try? FileManager.default.removeItem(at: testTypeSpecificStoreURL())
    }
    
    private func testTypeSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }

}
