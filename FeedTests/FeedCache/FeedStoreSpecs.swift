//
//  FeedStoreSpecs.swift
//  FeedTests
//
//  Created by Сергей Копаницкий on 11.02.2023.
//

import Foundation


protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCash()
    func test_retrieve_twiceCallDeliversEmptyOnEmptyCash()
    func test_retrieveAfterInsertingToEmptyCash_deliversInsertedValues()
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache()
    
    func test_insert_deliversNewInsertedValueOnNonEmptyCache()
    
    func test_delete_deleteOnEmptyCacheHasNoSideEffects()
    func test_delete_deletePrivioslyInsetredValues()
    
    func test_storeSideEffects_runSerially()
}

protocol FailableRetriveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieve_hasNoSideEffectsOnFailure()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_failureInsertHasNoSideEffects()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_failureDeletingHasNoSideEffects()
}

typealias FailableFeedStore = FailableRetriveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs
