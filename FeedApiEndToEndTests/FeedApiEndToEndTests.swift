//
//  FeedApiEndToEndTests.swift
//  FeedApiEndToEndTests
//
//  Created by Сергей Копаницкий on 31.01.2023.
//

import XCTest
import Feed

class FeedApiEndToEndTests: XCTestCase {

    func test_endToEndTestServerGETResult_matchesFixedTestAccountData() {
        switch getFeedResult() {
        case .success(let items):
            XCTAssertEqual(items.count, 8, "Exptect get 8 fixed items")
            XCTAssertEqual(items[0], getFeedItem(at: 0))
            XCTAssertEqual(items[1], getFeedItem(at: 1))
            XCTAssertEqual(items[2], getFeedItem(at: 2))
            XCTAssertEqual(items[3], getFeedItem(at: 3))
            XCTAssertEqual(items[4], getFeedItem(at: 4))
            XCTAssertEqual(items[5], getFeedItem(at: 5))
            XCTAssertEqual(items[6], getFeedItem(at: 6))
            XCTAssertEqual(items[7], getFeedItem(at: 7))
        case .failure(let error):
            XCTFail("Expect to get success result, but got error = \(error)")
        case .none:
            XCTFail("Expect to get result, but got nil response")
        }
    }
    
    // MARK: - Helpers
    private func getFeedResult() -> FeedLoaderResponse? {
        let url = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient()
        let loader = RemoteFeedLoader(client: client, url: url)
        let exp = expectation(description: "Wait to loader response")
        checkMemoryLeak(for: loader)
        checkMemoryLeak(for: client)
        
        var feedLoaderResponse: FeedLoaderResponse?
        
        loader.load { result in
            feedLoaderResponse = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
        return feedLoaderResponse
    }
    
    private func getFeedItem(at index: Int) -> FeedItem {
        return FeedItem(
            uuid: getUUID(at: index),
            description: getDescription(at: index),
            location: getLocation(at: index),
            imageURL: getImageURL(at: index))
    }
    
    private func getUUID(at index: Int) -> UUID {
        return [UUID(uuidString: "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6"),
                UUID(uuidString: "BA298A85-6275-48D3-8315-9C8F7C1CD109"),
                UUID(uuidString: "5A0D45B3-8E26-4385-8C5D-213E160A5E3C"),
                UUID(uuidString: "FF0ECFE2-2879-403F-8DBE-A83B4010B340"),
                UUID(uuidString: "DC97EF5E-2CC9-4905-A8AD-3C351C311001"),
                UUID(uuidString: "557D87F1-25D3-4D77-82E9-364B2ED9CB30"),
                UUID(uuidString: "A83284EF-C2DF-415D-AB73-2A9B8B04950B"),
                UUID(uuidString: "F79BD7F8-063F-46E2-8147-A67635C3BB01")][index]!
    }
    
    private func getDescription(at index: Int) -> String? {
        return ["Description 1",
                nil,
                "Description 3",
                nil,
                "Description 5",
                "Description 6",
                "Description 7",
                "Description 8"][index]
    }
    
    private func getLocation(at index: Int) -> String? {
        return ["Location 1",
                "Location 2",
                nil,
                nil,
                "Location 5",
                "Location 6",
                "Location 7",
                "Location 8"][index]
    }
    
    private func getImageURL(at index: Int) -> URL {
        return [URL(string: "https://url-1.com")!,
                URL(string: "https://url-2.com")!,
                URL(string: "https://url-3.com")!,
                URL(string: "https://url-4.com")!,
                URL(string: "https://url-5.com")!,
                URL(string: "https://url-6.com")!,
                URL(string: "https://url-7.com")!,
                URL(string: "https://url-8.com")!][index]
    }
}
