//
//  FeedTests.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 22.01.2023.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "https://google.com")
    }
}

class HTTPClient {
    
    static let shared = HTTPClient()
    
    private init() { }
    
    var requestedURL: URL?
}

class FeedTests: XCTestCase {
    
    func test_doesnt_fetch_request() {
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_request() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}
