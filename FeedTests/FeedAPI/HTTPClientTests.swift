//
//  HTTPClientTests.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 26.01.2023.
//

import XCTest
import Feed

class HTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLSessionStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLSessionStub.stopInterceptingRequests()
    }
    
    func test_fetchFromURL_requestsGivenURLForGetMethod() {
        let url = makeURL()
        let exp = expectation(description: "Wait closure")
        
        URLSessionStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_fetchFromURL_failsOnRequest() {
        let expextedError = anyNSError()
        let error = resultError(for: nil, response: nil, error: expextedError) as NSError?
        XCTAssertEqual(expextedError.code, error?.code)
    }
    
    func test_fetchFromURL_failsOnAllInvalidRepresentationCases() {
        let nonHTTPURLResponse = anyURLResponse()
        let anyHTTPURLResponse = anyHTTPURLResponse()
        let anyData = anyData()
        let anyError = anyNSError()
        
        XCTAssertNotNil(resultError(for: nil, response: nil, error: nil))
        XCTAssertNotNil(resultError(for: nil, response: nonHTTPURLResponse, error: nil))
        XCTAssertNotNil(resultError(for: anyData, response: nil, error: nil))
        XCTAssertNotNil(resultError(for: anyData, response: nil, error: anyError))
        XCTAssertNotNil(resultError(for: nil, response: nonHTTPURLResponse, error: anyError))
        XCTAssertNotNil(resultError(for: nil, response: anyHTTPURLResponse, error: anyError))
        XCTAssertNotNil(resultError(for: anyData, response: nonHTTPURLResponse, error: anyError))
        XCTAssertNotNil(resultError(for: anyData, response: anyHTTPURLResponse, error: anyError))
        XCTAssertNotNil(resultError(for: anyData, response: nonHTTPURLResponse, error: nil))
    }
    
    func test_fetchFromURL_requestReturnDataAndHTTPURLResponse() {
        let anyData = anyData()
        let anyHTTPURLResponse = anyHTTPURLResponse()
        let result = resultValue(for: anyData, response: anyHTTPURLResponse, error: nil)

        XCTAssertEqual(anyData, result?.0)
        XCTAssertEqual(anyHTTPURLResponse.url, result?.1.url)
        XCTAssertEqual(anyHTTPURLResponse.statusCode, result?.1.statusCode)
    }
    
    func test_fetchFromURL_requestReturnEmptyDataOnResponseAndNilData() {
        let anyHTTPURLResponse = anyHTTPURLResponse()
        let result = resultValue(for: nil, response: anyHTTPURLResponse, error: nil)
        let emptyData = Data()
        
        XCTAssertEqual(emptyData, result?.0)
        XCTAssertEqual(anyHTTPURLResponse.url, result?.1.url)
        XCTAssertEqual(anyHTTPURLResponse.statusCode, result?.1.statusCode)
    }
    
    private func makeSUT() -> HTTPClient {
        let sut = URLSessionHTTPClient()
        checkMemoryLeak(for: sut)
        return sut
    }
    
    private func makeURL() -> URL {
        return URL(string: "https://google.com")!
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1000, userInfo: nil)
    }
    
    private func anyURLResponse() -> URLResponse {
        return URLResponse(url: makeURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: makeURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func resultError(for data: Data?, response: URLResponse?, error: Error?) -> Error? {
        let result = resultFor(for: data, response: response, error: error)
        
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Exptect to get error")
            return nil
        }
    }
    
    private func resultValue(for data: Data?, response: URLResponse?, error: Error?) -> (Data, HTTPURLResponse)? {
        let result = resultFor(for: data, response: response, error: error)
        
        switch result {
        case .success(let data, let response):
            return (data, response)
        case .failure:
            XCTFail("Exptect to get value")
            return nil
        }
    }
    
    private func resultFor(for data: Data?, response: URLResponse?, error: Error?) -> HTTPClientResponse {
        let exp = expectation(description: "wait call completion")
        URLSessionStub.stub(data: data, response: response, error: error)
        var capturedResult: HTTPClientResponse!
        
        makeSUT().get(from: makeURL()) { result in
            capturedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        return capturedResult
    }
    
    private class URLSessionStub: URLProtocol {
        private struct Stub {
            let error: Error?
            let data: Data?
            let response: URLResponse?
        }
        
        private static var stub: Stub?
        private static var requestsObserver: ((URLRequest) -> Void)?
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = .init(error: error, data: data, response: response)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLSessionStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLSessionStub.self)
            stub = nil
            requestsObserver = nil
        }
        
        static func observeRequests(_ observer: @escaping ((URLRequest) -> Void)) {
            requestsObserver = observer
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let requestsObserver = URLSessionStub.requestsObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestsObserver(request)
            }
            
            if let data = URLSessionStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLSessionStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLSessionStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
    }
}
