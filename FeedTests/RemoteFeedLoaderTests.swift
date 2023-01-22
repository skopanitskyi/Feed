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
        let (client, _) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://google.com")!
        let (client, sut) = makeSUT(url: url)
        sut.load()
        
        XCTAssertEqual([url], client.requestedURLs)
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://google.com")!
        let (client, sut) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual([url, url], client.requestedURLs)
    }
    
    func test_load_returnsErrorInCompletion() {
        var returnedError: RemoteFeedLoader.Error?
        let (client, sut) = makeSUT()
        client.error = NSError(domain: "", code: 1)
        
        sut.load { error in
            returnedError = error
        }
        
        XCTAssertEqual(returnedError, .connectivity)
    }
    
    private func makeSUT(url: URL = URL(string: "https://google.com")!) -> (client: HTTPClientSpy, feedLoader: RemoteFeedLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (client, sut)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private(set) var requestedURLs: [URL] = []
        public var error: Error?
        
        func get(from url: URL, completion: @escaping ((Error) -> Void)) {
            if let error = error {
                completion(error)
            }
            
            requestedURLs.append(url)
        }
    }
}
