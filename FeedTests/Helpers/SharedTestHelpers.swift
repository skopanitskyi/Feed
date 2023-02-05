//
//  SharedTestHelpers.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 05.02.2023.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 1000, userInfo: nil)
}

func makeURL() -> URL {
    return URL(string: "https://google.com")!
}
