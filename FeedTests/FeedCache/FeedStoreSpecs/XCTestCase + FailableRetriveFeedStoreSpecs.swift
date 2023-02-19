//
//  XCTestCase + FailableRetriveFeedStoreSpecs.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 12.02.2023.
//

import XCTest
import Feed

extension FailableRetriveFeedStoreSpecs where Self: XCTestCase {
    func assertThatRetriveDeliversFailureOnRetrievalError(sut: FeedStore) {
        expact(sut, retriveResult: .failure(anyNSError()))
    }
    
    func assertThatRetriveHasNoSideEffectsOnFailure(sut: FeedStore) {        
        expact(sut, retriveResult: .failure(anyNSError()))
        expact(sut, retriveResult: .failure(anyNSError()))
    }
}
