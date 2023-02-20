//
//  XCTestCase + FailableInsertFeedStoreSpecs.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 12.02.2023.
//

import XCTest
import Feed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(sut: FeedStore) {
        insert(createImageFeed().localFeed, timestamp: Date(), sut: sut, expectedError: anyNSError())
    }
    
    func assertThatInsertFailureHasNoSideEffects(sut: FeedStore) {
        insert(createImageFeed().localFeed, timestamp: Date(), sut: sut, expectedError: anyNSError())
        expact(sut, retriveResult: .success(.none))
    }
}
