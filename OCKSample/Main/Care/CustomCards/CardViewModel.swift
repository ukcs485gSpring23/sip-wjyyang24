//
//  CardViewModel.swift
//  OCKSample
//
//  Created by Corey Baker on 4/25/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//
import CareKit
import CareKitStore
import CareKitUtilities
import Foundation
import SwiftUI

/**
 A basic view model that can be subclassed to make more intricate view models for custom
 CareKit cards.
 */
class CardViewModel: OCKTaskController {

    // MARK: Public read/write properties
    /// The latest `OCKOutcomeValue` available.
    @Published var value: OCKOutcomeValue?

    /// The error encountered by the view model.
    @Published public var currentError: Error?

    /// The `value` properly formatted in a `TextView`.
    var valueText: Text? {
        guard let value = value else {
            return nil
        }
        return Text(value.description)
    }

    /// The action performed when an outcome is to be saved
    var action: (OCKOutcomeValue?) async -> Void = { _ in }

    // MARK: Public read private write properties
    private(set) var query: SynchronizedTaskQuery?

    required init(storeManager: OCKSynchronizedStoreManager) {
        super.init(storeManager: storeManager)
        self.action = { value in
            do {
                guard let value = value else {
                    // No outcome to set
                    return
                }
                if self.taskEvents.firstEventOutcomeValues != nil {
                    _ = try await self.appendOutcomeValue(value: value,
                                                          at: .init(row: 0, section: 0))
                } else {
                    _ = try await self.saveOutcomesForEvent(atIndexPath: .init(row: 0, section: 0),
                                                            values: [value])
                }
            } catch {
                self.currentError = error
            }
        }
    }

    /// Create an instance for the default content. The first event that matches the
    /// provided query will be fetched from the the store and
    /// published to the view. The view will update when changes occur in the store.
    /// - Parameters:
    ///     - taskID: The ID of the task to fetch.
    ///     - eventQuery: A query used to fetch an event in the store.
    ///     - storeManager: Wraps the store that contains the event to fetch.
    convenience init(taskID: String,
                     eventQuery: OCKEventQuery,
                     storeManager: OCKSynchronizedStoreManager) {
        self.init(storeManager: storeManager)
        setQuery(.taskIDs([taskID], eventQuery))
        self.query?.perform(using: self)
    }

    /// Create an instance for the default content. The first event that matches the
    /// provided query will be fetched from the the store and
    /// published to the view. The view will update when changes occur in the store.
    /// - Parameters:
    ///     - task: The task associated with the event to fetch.
    ///     - eventQuery: A query used to fetch an event in the store.
    ///     - storeManager: Wraps the store that contains the event to fetch.
    convenience init(task: OCKAnyTask,
                     eventQuery: OCKEventQuery,
                     storeManager: OCKSynchronizedStoreManager) {
        self.init(storeManager: storeManager)
        setQuery(.tasks([task], eventQuery))
        self.query?.perform(using: self)
    }

    /// Create an instance for the default content. The first event that matches the
    /// provided query will be fetched from the the store and
    /// published to the view. The view will update when changes occur in the store.
    /// - Parameters:
    ///     - taskID: The ID of the task to fetch.
    ///     - eventQuery: A query used to fetch an event in the store.
    ///     - storeManager: Wraps the store that contains the event to fetch.
    convenience init(taskID: String,
                     eventQuery: OCKEventQuery,
                     storeManager: OCKSynchronizedStoreManager,
                     action: ((OCKOutcomeValue?) async -> Void)?) {
        self.init(storeManager: storeManager)
        setQuery(.taskIDs([taskID], eventQuery))
        if let action = action {
            self.action = action
        }
        self.query?.perform(using: self)
    }

    /// Create an instance for the default content. The first event that matches the
    /// provided query will be fetched from the the store and
    /// published to the view. The view will update when changes occur in the store.
    /// - Parameters:
    ///     - task: The task associated with the event to fetch.
    ///     - eventQuery: A query used to fetch an event in the store.
    ///     - storeManager: Wraps the store that contains the event to fetch.
    convenience init(task: OCKAnyTask,
                     eventQuery: OCKEventQuery,
                     storeManager: OCKSynchronizedStoreManager,
                     action: ((OCKOutcomeValue?) async -> Void)?) {
        self.init(storeManager: storeManager)
        setQuery(.tasks([task], eventQuery))
        if let action = action {
            self.action = action
        }
        self.query?.perform(using: self)
    }

    /**
     Set the query property for this class.
     - parameter query: The query to keep in sync with this view model.
     */
    func setQuery(_ query: SynchronizedTaskQuery) {
        self.query = query
    }

    @MainActor
    func checkIfValueShouldUpdate(_ updatedEvents: OCKTaskEvents) {
        if let changedValue = updatedEvents.firstEventOutcomeValueDouble,
            self.value != OCKOutcomeValue(changedValue) {
            self.value = OCKOutcomeValue(changedValue)
        }
    }

    @MainActor
    func setError(_ updatedError: Error?) {
        self.currentError = updatedError
    }
}

extension CardViewModel {
    /// Creates a query that can be used to synchronize `CardViewModel`'s.
    enum SynchronizedTaskQuery {

        case taskQuery(_ taskQuery: OCKTaskQuery, _ eventQuery: OCKEventQuery)
        case taskIDs(_ taskIDs: [String], _ eventQuery: OCKEventQuery)

        static func tasks(_ tasks: [OCKAnyTask], _ eventQuery: OCKEventQuery) -> Self {
            let taskIDs = Array(Set(tasks.map { $0.id }))
            return .taskIDs(taskIDs, eventQuery)
        }

        func perform(using viewModel: CardViewModel) {
            switch self {
            case let .taskQuery(taskQuery, eventQuery):
                viewModel.fetchAndObserveEvents(forTaskQuery: taskQuery, eventQuery: eventQuery)
            case let .taskIDs(taskIDs, eventQuery):
                viewModel.fetchAndObserveEvents(forTaskIDs: taskIDs, eventQuery: eventQuery)
            }
        }
    }
}
