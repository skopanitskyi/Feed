//
//  FeedTests.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 22.01.2023.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "https://google.com")!)
    }
}

class HTTPClient {
    static var shared = HTTPClient()
        
    public func get(from url: URL) { }
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    public override func get(from url: URL) {
        requestedURL = url
    }
}

class FeedTests: XCTestCase {
    
    func test_doesnt_fetch_request() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_request() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}
