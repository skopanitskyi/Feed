//
//  LoadFeedFromRemoteUseCaseTests.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 02.02.2023.
//

import XCTest
import Feed

class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    
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
        
        expext(sut, withResponse: failure(.connectivity)) {
            client.complete(with: error)
        }
    }
    
    func test_load_returnsErrorOnInvalidStatusCode() {
        let (client, sut) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expext(sut, withResponse: failure(.invalidData)) {
                let json = createItemsJsonData([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_returnsErrorWithStatusCode200OnInvalidJSON() {
        let (client, sut) = makeSUT()
        
        expext(sut, withResponse: failure(.invalidData)) {
            let data = Data("Test json".utf8)
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    func test_load_returnsEmptyFeedItemsListOnStatusCode200AndEmptyJSON() {
        let (client, sut) = makeSUT()
        let data = createItemsJsonData([])
        
        expext(sut, withResponse: .success([])) {
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    func test_load_returnsFeedItemsListOnStatusCode200() {
        let (client, sut) = makeSUT()
        
        let item1 = getItem(
            uuid: UUID(),
            imageURL: URL(string: "https://google.com")!)
        
        let item2 = getItem(
            uuid: UUID(),
            description: "test1",
            location: "test2",
            imageURL: URL(string: "https://google.com")!)
        
        let item3 = getItem(
            uuid: UUID(),
            location: "test3",
            imageURL: URL(string: "https://google.com")!)

        let item4 = getItem(
            uuid: UUID(),
            description: "test4",
            imageURL: URL(string: "https://google.com")!)
        
        let data = createItemsJsonData([item1.json, item2.json, item3.json, item4.json])
        
        expext(sut, withResponse: .success([item1.model, item2.model, item3.model, item4.model])) {
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    func test_load_completionBlockDoesntCalledWhenObjectIsNil() {
        let url = URL(string: "https://google.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(client: client, url: url)
        
        var returnedResponses: [RemoteFeedLoader.Response] = []
        sut?.load { response in returnedResponses.append(response) }

        sut = nil
        client.complete(withStatusCode: 200, data: createItemsJsonData([]))
        
        XCTAssertTrue(returnedResponses.isEmpty)
    }
    
    private func makeSUT(url: URL = URL(string: "https://google.com")!) -> (client: HTTPClientSpy, feedLoader: RemoteFeedLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        checkMemoryLeak(for: sut)
        checkMemoryLeak(for: client)
        return (client, sut)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Response {
        return .failure(error)
    }
    
    private func expext(_ sut: RemoteFeedLoader, withResponse response: RemoteFeedLoader.Response, action: () -> Void) {

        let exp = expectation(description: "wait closure")
        
        sut.load { result in
            switch (result, response) {
            case (.success(let items), .success(let expectedItems)):
                XCTAssertEqual(items, expectedItems)
            case (.failure(let error as RemoteFeedLoader.Error), .failure(let expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(error, expectedError)
            default:
                XCTFail()
            }
            exp.fulfill()
        }
                
        action()
        
        wait(for: [exp], timeout: 1)
    }
    
    private func getItem(
        uuid: UUID,
        description: String? = nil,
        location: String? = nil,
        imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
            let item = FeedItem(uuid: uuid, description: description, location: location, imageURL: imageURL)
            let json = [
                "id": uuid.uuidString,
                "description": description,
                "location": location,
                "image": imageURL.absoluteString
            ].compactMapValues { $0 }
            
            return (item, json)
        }
    
    private func createItemsJsonData(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
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
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: messages[index].url,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}
