//
//  FeedTests.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 22.01.2023.
//

import XCTest
import Feed

class FeedTests: XCTestCase {
    
    func test_doesnt_fetch_request() {
        let url = URL(string: "https://google.com")!
        let (client, _) = makeSUT(url: url)
        
        XCTAssertNil(client.requestedURL)
        XCTAssertNotEqual(url, client.requestedURL)
    }
    
    func test_load_request() {
        let url = URL(string: "https://google.com")!
        let (client, sut) = makeSUT(url: url)
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
        XCTAssertEqual(url, client.requestedURL)
    }
    
    private func makeSUT(url: URL) -> (client: HTTPClientSpy, feedLoader: RemoteFeedLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (client, sut)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }
    }
}
