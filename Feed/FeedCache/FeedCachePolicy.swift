//
//  FeedCachePolicy.swift
//  Feed
//
//  Created by Сергей Копаницкий on 07.02.2023.
//

import Foundation

public final class FeedCachePolicy {
    
    private static let maxCacheAgeInDays = 7
    
    private init() { }
    
    public static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = Calendar.current.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
