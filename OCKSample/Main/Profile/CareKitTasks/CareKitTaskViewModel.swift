//
//  CareKitTaskViewModel.swift
//  OCKSample
//
//  Created by  on 3/21/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore
import os.log

class CareKitTaskViewModel: ObservableObject {
    @Published var title = ""
    @Published var instructions = ""
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var hourAndMinute = Date()
    @Published var selectedCard: CareKitCard = .button
    @Published var isShowingAddedAlert = false
    @Published var isShowingDateAlert = false
    @Published var error: AppError? {
        willSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    private(set) var alertMessage = "Task added successfully!"

    // MARK: Intents
    @MainActor
    func addTask() async {
        guard let appDelegate = AppDelegateKey.defaultValue else {
            error = AppError.couldntBeUnwrapped
            return
        }
        let uniqueId = UUID().uuidString // Create a unique id for each task
        let calendar = Calendar.current
        var task: OCKTask
        guard startDate < endDate else {
            alertMessage = "Please make sure that the start date is before end date"
            isShowingAddedAlert = true
            return
        }
        task = OCKTask(id: uniqueId,
                           title: title,
                           carePlanUUID: nil,
                           schedule: .dailyAtTime(hour: calendar.component(.hour, from: hourAndMinute),
                                                  minutes: calendar.component(.minute, from: hourAndMinute),
                                                  start: startDate,
                                                  end: endDate,
                                                  text: nil))
        task.instructions = instructions
        task.card = selectedCard

        do {
            try await appDelegate.storeManager.addTasksIfNotPresent([task])
            Logger.careKitTask.info("Saved task: \(task.id, privacy: .private)")
            // Notify views they should refresh tasks if needed
            NotificationCenter.default.post(.init(name: Notification.Name(rawValue: Constants.shouldRefreshView)))
            alertMessage = "Task added successfully!"
            isShowingAddedAlert = true
        } catch {
            alertMessage = "Error: Failed to add task"
            isShowingAddedAlert = true
            self.error = AppError.errorString("Could not add task: \(error.localizedDescription)")
        }
    }

    @MainActor
    func addHealthKitTask() async {
        guard let appDelegate = AppDelegateKey.defaultValue else {
            error = AppError.couldntBeUnwrapped
            return
        }
        let uniqueId = UUID().uuidString // Create a unique id for each task
        let calendar = Calendar.current
        guard startDate < endDate else {
            alertMessage = "Please make sure that the start date is before end date"
            isShowingAddedAlert = true
            return
        }
        var healthKitTask = OCKHealthKitTask(id: uniqueId,
                                             title: title,
                                             carePlanUUID: nil,
                                             // swiftlint:disable:next line_length
                                             schedule: .dailyAtTime(hour: calendar.component(.hour, from: hourAndMinute),
                                             // swiftlint:disable:next line_length
                                                                    minutes: calendar.component(.minute, from: hourAndMinute),
                                                                    start: startDate,
                                                                    end: endDate,
                                                                    text: nil),
                                             healthKitLinkage: .init(quantityIdentifier: .electrodermalActivity,
                                                                     quantityType: .discrete,
                                                                     unit: .count()))
        healthKitTask.instructions = instructions
        healthKitTask.card = selectedCard
        do {
            try await appDelegate.storeManager.addTasksIfNotPresent([healthKitTask])
            Logger.careKitTask.info("Saved HealthKitTask: \(healthKitTask.id, privacy: .private)")
            // Notify views they should refresh tasks if needed
            NotificationCenter.default.post(.init(name: Notification.Name(rawValue: Constants.shouldRefreshView)))
            // Ask HealthKit store for permissions after each new task
            Utility.requestHealthKitPermissions()
            alertMessage = "Task added successfully!"
            isShowingAddedAlert = true
        } catch {
            alertMessage = "Error: Failed to add task"
            isShowingAddedAlert = true
            self.error = AppError.errorString("Could not add task: \(error.localizedDescription)")
        }
    }
}
