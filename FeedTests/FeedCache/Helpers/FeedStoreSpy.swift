//
//  FeedStoreSpy.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 04.02.2023.
//

import Foundation
import Feed

class FeedStoreSpy: FeedStore {
    
    private(set) var receivedMessages: [ReceivedMessages] = []
    
    private var capturedDeletionCompletions: [DeletionCompletion] = []
    private var capturedInsertionCompletions: [InsertionCompletion] = []
    private var capturedRetriveCompletion: [RetriveCompletion] = []
    
    public enum ReceivedMessages: Equatable {
        case deleteCacheFeed
        case insert(feed: [LocalFeedImage], timestamp: Date)
        case retrive
    }
    
    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        receivedMessages.append(.deleteCacheFeed)
        capturedDeletionCompletions.append(completion)
    }
    
    public func completeDeletion(with error: Error, at index: Int = .zero) {
        capturedDeletionCompletions[index](error)
    }
    
    public func completeDeletionSuccessfully(at index: Int = .zero) {
        capturedDeletionCompletions[index](nil)
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        receivedMessages.append(.insert(feed: feed, timestamp: timestamp))
        capturedInsertionCompletions.append(completion)
    }
    
    public func completeInsertion(with error: Error, at index: Int = .zero) {
        capturedInsertionCompletions[index](error)
    }
    
    public func completeInsertionSuccessfully(at index: Int = .zero) {
        capturedInsertionCompletions[index](nil)
    }
    
    public func retrive(completion: @escaping RetriveCompletion) {
        receivedMessages.append(.retrive)
        capturedRetriveCompletion.append(completion)
    }
    
    public func completeRetrival(with error: Error, at index: Int = .zero) {
        capturedRetriveCompletion[index](.failure(error))
    }
    
    public func completeRetriveEmptyCache(at index: Int = .zero) {
        capturedRetriveCompletion[index](.empty)
    }
    
    public func completeRetriveCache(_ feed: [LocalFeedImage], timestamp: Date, at index: Int = .zero) {
        capturedRetriveCompletion[index](.found(feed: feed, timestamp: timestamp))
    }
}
