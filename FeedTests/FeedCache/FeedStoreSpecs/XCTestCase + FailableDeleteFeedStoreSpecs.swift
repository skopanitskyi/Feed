//
//  XCTestCase + FailableDeleteFeedStoreSpecs.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 12.02.2023.
//

import XCTest
import Feed

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
    func assertThatDeleteDeliversErrorOnDeletionError(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let deletionError = delete(from: sut)
        XCTAssertNotNil(deletionError, "Expect to get error on deletion invalid data url, but got nil")
    }
    
    func assertThatDeleteFailureDeletingHasNoSideEffects(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        delete(from: sut)
        expact(sut, retriveResult: .success(.none))
    }
}
