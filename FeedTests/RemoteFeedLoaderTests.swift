//
//  FeedTests.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 22.01.2023.
//

import XCTest
import Feed

class FeedTests: XCTestCase {
    
    func test_init_doesntFetchRequest() {
        let url = URL(string: "https://google.com")!
        let (client, _) = makeSUT(url: url)
        
        XCTAssertNil(client.requestedURL)
        XCTAssertNotEqual(url, client.requestedURL)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://google.com")!
        let (client, sut) = makeSUT(url: url)
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
        XCTAssertEqual(url, client.requestedURL)
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://google.com")!
        let (client, sut) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
        XCTAssertEqual(url, client.requestedURL)
        XCTAssertEqual([url, url], client.requestedURLs)
    }
    
    private func makeSUT(url: URL) -> (client: HTTPClientSpy, feedLoader: RemoteFeedLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (client, sut)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private(set) var requestedURL: URL?
        private(set) var requestedURLs: [URL] = []
        
        func get(from url: URL) {
            requestedURL = url
            requestedURLs.append(url)
        }
    }
}
