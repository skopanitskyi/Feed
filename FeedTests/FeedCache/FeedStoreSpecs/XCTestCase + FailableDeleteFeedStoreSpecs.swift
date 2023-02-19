//
//  XCTestCase + FailableDeleteFeedStoreSpecs.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 12.02.2023.
//

import XCTest
import Feed

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
    func assertThatDeleteDeliversErrorOnDeletionError(sut: FeedStore) {
        let deletionError = delete(from: sut)
        XCTAssertNotNil(deletionError, "Expect to get error on deletion invalid data url, but got nil")
    }
    
    func assertThatDeleteFailureDeletingHasNoSideEffects(sut: FeedStore) {
        delete(from: sut)
        expact(sut, retriveResult: .empty)
    }
}
