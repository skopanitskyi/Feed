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
        sut.load { _ in }
        
        XCTAssertEqual([url], client.requestedURLs)
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://google.com")!
        let (client, sut) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual([url, url], client.requestedURLs)
    }
    
    func test_load_returnsErrorInCompletion() {
        var returnedErrors: [RemoteFeedLoader.Error] = []
        let (client, sut) = makeSUT()
        let error = NSError(domain: "", code: 1)
        
        sut.load { error in
            returnedErrors.append(error)
        }
        client.complete(with: error)
        
        XCTAssertEqual(returnedErrors, [.connectivity])
    }
    
    func test_load_returnsErrorOnInvalidStatusCode() {
        let (client, sut) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            var returnedErrors: [RemoteFeedLoader.Error] = []
            sut.load { error in
                returnedErrors.append(error)
            }
            client.complete(withStatusCode: code, at: index)
            XCTAssertEqual(returnedErrors, [.invalidData])
        }
    }
    
    private func makeSUT(url: URL = URL(string: "https://google.com")!) -> (client: HTTPClientSpy, feedLoader: RemoteFeedLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (client, sut)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        private var messages: [(url: URL, completion: (Result<HTTPURLResponse, Error>) -> Void)] = []
        
        func get(from url: URL, completion: @escaping ((Result<HTTPURLResponse, Error>) -> Void)) {
            messages.append((url: url, completion: completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: messages[index].url,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success(response))
        }
    }
}
