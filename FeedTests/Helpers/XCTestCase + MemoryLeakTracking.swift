//
//  XCTestCase + MemoryLeakTracking.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 30.01.2023.
//

import XCTest

extension XCTestCase {
    public func checkMemoryLeak(for object: AnyObject) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object)
        }
    }
}
