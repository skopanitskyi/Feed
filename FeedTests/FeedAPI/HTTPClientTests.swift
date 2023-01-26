//
//  HTTPClientTests.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 26.01.2023.
//

import XCTest
import Feed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func fetch(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }
    }
    
}

class HTTPClientTests: XCTestCase {
    
    func test_fetchFromURL_retrunDataTaskWithURL() {
        let url = URL(string: "https://google.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.fetch(from: url)
        
        XCTAssertEqual(session.caputedURLs, [url])
    }
    
    private class URLSessionSpy: URLSession {
        var caputedURLs: [URL] = []
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            caputedURLs.append(url)
            return URLSessionFakeDataTask()
        }
    }
    
    private class URLSessionFakeDataTask: URLSessionDataTask { }
    
}
