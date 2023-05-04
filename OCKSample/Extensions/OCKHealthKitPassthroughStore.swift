//
//  OCKHealthKitPassthroughStore.swift
//  OCKSample
//
//  Created by Corey Baker on 1/5/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//
import Foundation
import CareKitStore
import HealthKit
import os.log

extension OCKHealthKitPassthroughStore {

    func addTasksIfNotPresent(_ tasks: [OCKHealthKitTask]) async throws {
        let tasksToAdd = tasks
        let taskIdsToAdd = tasksToAdd.compactMap { $0.id }

        // Prepare query to see if tasks are already added
        var query = OCKTaskQuery(for: Date())
        query.ids = taskIdsToAdd

        let foundTasks = try await fetchTasks(query: query)
        var tasksNotInStore = [OCKHealthKitTask]()

        // Check results to see if there's a missing task
        tasksToAdd.forEach { potentialTask in
            if foundTasks.first(where: { $0.id == potentialTask.id }) == nil {
                tasksNotInStore.append(potentialTask)
            }
        }

        // Only add if there's a new task
        if tasksNotInStore.count > 0 {
            do {
                _ = try await addTasks(tasksNotInStore)
                Logger.ockHealthKitPassthroughStore.info("Added tasks into HealthKitPassthroughStore!")
            } catch {
                Logger.ockHealthKitPassthroughStore.error("Error adding HealthKitTasks: \(error)")
            }
        }
    }

    func populateSampleData(_ patientUUID: UUID? = nil) async throws {
        let carePlanUUIDs = try await OCKStore.getCarePlanUUIDs()
//        var carePlanUUID = UUID()
//        var query = OCKCarePlanQuery(for: Date())
//        if let unwrappedPatientUUID = patientUUID {
//            query.patientUUIDs.append(unwrappedPatientUUID)
//            guard let appDelegate = AppDelegateKey.defaultValue,
//                  let foundCarePlan = try await appDelegate.store?.fetchCarePlans(query: query),
//                  let carePlan = foundCarePlan.first else {
//                Logger.ockStore.error("Could not find care plan with patient id \"\(unwrappedPatientUUID)\".")
//                return
//            }
//            carePlanUUID = carePlan.uuid
//        } else {
//            Logger.ockStore.error("No valid patientUUID")
//        }

        let schedule = OCKSchedule.dailyAtTime(
            hour: 8, minutes: 0, start: Date(), end: nil, text: nil,
            duration: .hours(12), targetValues: [OCKOutcomeValue(10000.0, units: "Steps")])

        let flightsSchedule = OCKSchedule.dailyAtTime(
            hour: 8, minutes: 0, start: Date(), end: nil, text: nil,
            duration: .hours(12), targetValues: [OCKOutcomeValue(10, units: "Flights of Stairs")])

        var flightsClimbed = OCKHealthKitTask(
            id: TaskID.flightsClimbed,
            title: "Flights Climbed 📈",
            carePlanUUID: carePlanUUIDs[CarePlanID.health],
            schedule: flightsSchedule,
            healthKitLinkage: OCKHealthKitLinkage(
                quantityIdentifier: .flightsClimbed,
                quantityType: .cumulative,
                unit: HKUnit.count()))
        flightsClimbed.card = .numericProgress
        flightsClimbed.graph = .bar
        flightsClimbed.groupIdentifier = "Flights climbed" // unit for data series legend
        flightsClimbed.instructions = "Climbing a flight of stairs can be great exercise"
        flightsClimbed.asset = "nature_stairs.jpg"

        var steps = OCKHealthKitTask(
            id: TaskID.steps,
            title: "Steps 👣",
            carePlanUUID: carePlanUUIDs[CarePlanID.checkIn],
            schedule: schedule,
            healthKitLinkage: OCKHealthKitLinkage(
                quantityIdentifier: .stepCount,
                quantityType: .cumulative,
                unit: .count()))
        steps.asset = "figure.walk"
        steps.card = .numericProgress
        steps.graph = .bar
        steps.groupIdentifier = "Steps" // unit for data series legend
        steps.instructions = "Aim for 10,000 steps each day!"
        steps.asset = "dune_walk.jpg"

        try await addTasksIfNotPresent([steps, flightsClimbed])
    }
}
