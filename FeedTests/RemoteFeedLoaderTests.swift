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
        let (client, sut) = makeSUT()
        let error = NSError(domain: "", code: 1)
        
        expext(sut, withResponse: .failure(.connectivity)) {
            client.complete(with: error)
        }
    }
    
    func test_load_returnsErrorOnInvalidStatusCode() {
        let (client, sut) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expext(sut, withResponse: .failure(.invalidData)) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_returnsErrorWithStatusCode200OnInvalidJSON() {
        let (client, sut) = makeSUT()
        
        expext(sut, withResponse: .failure(.invalidData)) {
            let data = Data("Test json".utf8)
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    func test_load_returnsEmptyFeedItemsListOnStatusCode200AndEmptyJSON() {
        let (client, sut) = makeSUT()
        let data = Data("{ \"items\": [] } ".utf8)
        
        expext(sut, withResponse: .success([])) {
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    func test_load_returnsFeedItemsListOnStatusCode200() {
        let (client, sut) = makeSUT()
        
        let item1 = FeedItem(
            uuid: UUID(),
            description: nil,
            location: nil,
            imageURL: URL(string: "https://google.com")!)
        
        let item1Dictionary = ["uuid": item1.uuid.uuidString,
                               "image": item1.imageURL.absoluteString]
        
        let item2 = FeedItem(
            uuid: UUID(),
            description: "test1",
            location: "test2",
            imageURL: URL(string: "https://google.com")!)
        
        let item2Dictionary = ["uuid": item2.uuid.uuidString,
                               "description": item2.description,
                               "location": item2.location,
                               "image": item2.imageURL.absoluteString]
        
        let item3 = FeedItem(
            uuid: UUID(),
            description: nil,
            location: "test3",
            imageURL: URL(string: "https://google.com")!)
        
        let item3Dictionary = ["uuid": item3.uuid.uuidString,
                               "location": item3.location,
                               "image": item3.imageURL.absoluteString]
        
        let item4 = FeedItem(
            uuid: UUID(),
            description: "test4",
            location: nil,
            imageURL: URL(string: "https://google.com")!)
        
        let item4Dictionary = ["uuid": item4.uuid.uuidString,
                               "description": item4.description,
                               "image": item4.imageURL.absoluteString]
        
        let itemsJson = [
            "items": [item1Dictionary, item2Dictionary, item3Dictionary, item4Dictionary]
        ]
        
        let data = try! JSONSerialization.data(withJSONObject: itemsJson)
        
        expext(sut, withResponse: .success([item1, item2, item3, item4])) {
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    private func makeSUT(url: URL = URL(string: "https://google.com")!) -> (client: HTTPClientSpy, feedLoader: RemoteFeedLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (client, sut)
    }
    
    private func expext(_ sut: RemoteFeedLoader, withResponse response: RemoteFeedLoader.Response, action: () -> Void) {
        var returnedResponses: [RemoteFeedLoader.Response] = []

        sut.load { response in returnedResponses.append(response) }
        action()
        
        XCTAssertEqual(returnedResponses, [response])
        
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        private var messages: [(url: URL, completion: (HTTPClientResponse) -> Void)] = []
        
        func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void) {
            messages.append((url: url, completion: completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: messages[index].url,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}
