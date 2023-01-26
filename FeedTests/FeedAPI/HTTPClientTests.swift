//
//  HTTPClientTests.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 26.01.2023.
//

import XCTest
import Feed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPClient {
    private let session: HTTPSession
    
    init(session: HTTPSession) {
        self.session = session
    }
    
    func fetch(from url: URL, completion: @escaping (HTTPClientResponse) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
    
}

class HTTPClientTests: XCTestCase {
    
    func test_fetchFromURL_callResumeOnce() {
        let url = URL(string: "https://google.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        let sut = URLSessionHTTPClient(session: session)
        session.stub(url, task)
        
        sut.fetch(from: url) { _ in }
        XCTAssertEqual(task.resumeCalledCount, 1)
    }
    
    func test_fetchFromURL_failsOnRequest() {
        
        let url = URL(string: "https://google.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        let sut = URLSessionHTTPClient(session: session)
        let expextedError = NSError(domain: "test error", code: 1)
        session.stub(url, task, error: expextedError)
        
        let exp = expectation(description: "wait call completion")
        
        sut.fetch(from: url) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error as NSError):
                XCTAssertEqual(expextedError, error)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private class URLSessionSpy: HTTPSession {
        var caputedURLs: [URL] = []
        private var stubs: [URL: Stub] = [:]
        
        func stub(_ url: URL, _ dataTask: HTTPSessionTask = URLSessionDataTaskSpy(), error: Error? = nil) {
            stubs[url] = .init(dataTask: dataTask, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
            caputedURLs.append(url)
            guard let stub = stubs[url] else {
                fatalError("didn't faind stub")
            }
            completionHandler(nil, nil, stub.error)
            return stub.dataTask
        }
    }
    
    private struct Stub {
        let dataTask: HTTPSessionTask
        let error: Error?
    }
    
    private class URLSessionDataTaskSpy: HTTPSessionTask {
        var resumeCalledCount: Int = .zero
        
        func resume() {
            resumeCalledCount += 1
        }
    }
}
