//
//  OCKStore.swift
//  OCKSample
//
//  Created by Corey Baker on 1/5/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//
import Foundation
import CareKitStore
import Contacts
import os.log
import ParseSwift
import ParseCareKit
import SwiftUI

extension OCKStore {

    func addTasksIfNotPresent(_ tasks: [OCKTask]) async throws {
        let taskIdsToAdd = tasks.compactMap { $0.id }

        // Prepare query to see if tasks are already added
        var query = OCKTaskQuery(for: Date())
        query.ids = taskIdsToAdd

        let foundTasks = try await fetchTasks(query: query)
        var tasksNotInStore = [OCKTask]()

        // Check results to see if there's a missing task
        tasks.forEach { potentialTask in
            if foundTasks.first(where: { $0.id == potentialTask.id }) == nil {
                tasksNotInStore.append(potentialTask)
            }
        }

        // Only add if there's a new task
        if tasksNotInStore.count > 0 {
            do {
                _ = try await addTasks(tasksNotInStore)
                Logger.ockStore.info("Added tasks into OCKStore!")
            } catch {
                Logger.ockStore.error("Error adding tasks: \(error)")
            }
        }
    }

    func populateCarePlans(patientUUID: UUID? = nil) async throws {
        let checkInCarePlan = OCKCarePlan(id: CarePlanID.checkIn.rawValue,
                                          title: "Check in Care Plan",
                                          patientUUID: patientUUID)
        let healthCarePlan = OCKCarePlan(id: CarePlanID.health.rawValue,
                                         title: "Health Care Plan",
                                         patientUUID: patientUUID)
        let productivityCarePlan = OCKCarePlan(id: CarePlanID.productivity.rawValue,
                                          title: "Productivity Care Plan",
                                          patientUUID: patientUUID)
        let dietCarePlan = OCKCarePlan(id: CarePlanID.diet.rawValue,
                                          title: "Diet Care Plan",
                                          patientUUID: patientUUID)
        try await AppDelegateKey
            .defaultValue?
            .storeManager
            .addCarePlansIfNotPresent([checkInCarePlan, healthCarePlan,
                                       productivityCarePlan, dietCarePlan],
                                      patientUUID: patientUUID)
    }

    @MainActor
    class func getCarePlanUUIDs() async throws -> [CarePlanID: UUID] {
        var results = [CarePlanID: UUID]()

        guard let store = AppDelegateKey.defaultValue?.store else {
            return results
        }

        var query = OCKCarePlanQuery(for: Date())
        query.ids = [CarePlanID.health.rawValue,
                     CarePlanID.checkIn.rawValue]

        let foundCarePlans = try await store.fetchCarePlans(query: query)
        // Populate the dictionary for all CarePlan's
        CarePlanID.allCases.forEach { carePlanID in
            results[carePlanID] = foundCarePlans
                .first(where: { $0.id == carePlanID.rawValue })?.uuid
        }
        return results
    }

    func addContactsIfNotPresent(_ contacts: [OCKContact]) async throws {
        let contactIdsToAdd = contacts.compactMap { $0.id }

        // Prepare query to see if contacts are already added
        var query = OCKContactQuery(for: Date())
        query.ids = contactIdsToAdd

        let foundContacts = try await fetchContacts(query: query)
        var contactsNotInStore = [OCKContact]()

        // Check results to see if there's a missing task
        contacts.forEach { potential in
            if foundContacts.first(where: { $0.id == potential.id }) == nil {
                contactsNotInStore.append(potential)
            }
        }

        // Only add if there's a new task
        if contactsNotInStore.count > 0 {
            do {
                _ = try await addContacts(contactsNotInStore)
                Logger.ockStore.info("Added contacts into OCKStore!")
            } catch {
                Logger.ockStore.error("Error adding contacts: \(error)")
            }
        }
    }

    // Adds tasks and contacts into the store
    func populateSampleData(_ patientUUID: UUID? = nil) async throws {

        try await populateCarePlans(patientUUID: patientUUID)

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
        let carePlanUUIDs = try await OCKStore.getCarePlanUUIDs()

        let thisMorning = Calendar.current.startOfDay(for: Date())
        guard let aFewDaysAgo = Calendar.current.date(byAdding: .day, value: -4, to: thisMorning),
              let beforeBreakfast = Calendar.current.date(byAdding: .hour, value: 8, to: aFewDaysAgo) else {
            Logger.ockStore.error("Could not unwrap calendar. Should never hit")
            throw AppError.couldntBeUnwrapped
        }

        let fruitElement = OCKScheduleElement(start: beforeBreakfast,
                                               end: nil,
                                               interval: DateComponents(day: 1),
                                               text: "Eat a fruit",
                                               targetValues: [], duration: .allDay)
        let veggiesLunchElement = OCKScheduleElement(start: beforeBreakfast,
                                                end: nil,
                                                interval: DateComponents(day: 1),
                                                text: "Eat veggies (lunch)",
                                                targetValues: [], duration: .allDay)
        let veggiesDinnerElement = OCKScheduleElement(start: beforeBreakfast,
                                                end: nil,
                                                interval: DateComponents(day: 1),
                                                text: "Eat veggies (dinner)",
                                                targetValues: [], duration: .allDay)
        let proteinElement = OCKScheduleElement(start: beforeBreakfast,
                                                end: nil,
                                                interval: DateComponents(day: 1),
                                                text: "Eat a protein every meal",
                                                targetValues: [], duration: .allDay)
        let dietSchedule = OCKSchedule(composing: [fruitElement, veggiesLunchElement,
                                                    veggiesDinnerElement, proteinElement])
        var diet = OCKTask(id: TaskID.diet,
                             title: "Eat a balanced diet 🥗",
                             carePlanUUID: carePlanUUIDs[CarePlanID.diet],
                             schedule: dietSchedule)
        diet.impactsAdherence = false
        diet.instructions = "Aim to eat from all of the food groups!"
        diet.asset = "diet.jpg"
        diet.card = .checklist
        diet.graph = .line
        diet.groupIdentifier = "Food Groups"

        let waterSchedule = OCKSchedule(composing: [
            OCKScheduleElement(start: beforeBreakfast,
                               end: nil,
                               interval: DateComponents(day: 1),
                               text: "Aim for 8 cups or more each day!",
                               targetValues: [OCKOutcomeValue(8, units: "Cups")],
                               duration: .allDay)
            ])
        var water = OCKTask(id: TaskID.water,
                            title: "Stay hydrated 💧",
                            carePlanUUID: carePlanUUIDs[CarePlanID.health],
                            schedule: waterSchedule)
        water.impactsAdherence = false
        water.instructions = "Log every time you drink a cup of water."
        water.asset = "water-drop"
        water.card = .button
        water.graph = .bar
        water.groupIdentifier = "Cups" // unit for data series legend

        let planElement = OCKScheduleElement(start: beforeBreakfast,
                                                end: nil,
                                                interval: DateComponents(day: 1),
                                                text: "",
                                                targetValues: [], duration: .allDay)
        let planSchedule = OCKSchedule(composing: [planElement])
        var plan = OCKTask(id: TaskID.plan,
                           title: "Plan out your day ☀️",
                           carePlanUUID: carePlanUUIDs[CarePlanID.productivity],
                           schedule: planSchedule)
        plan.impactsAdherence = false
        plan.instructions = "Use these resources to plan your day out!"
        plan.asset = "planner.jpg"
        plan.card = .plan
        plan.graph = .scatter
        plan.groupIdentifier = "Plan" // unit for data series legend

        let sugaryDrinksElement = OCKScheduleElement(start: beforeBreakfast,
                                                end: nil,
                                                interval: DateComponents(day: 1),
                                                text: "Drinks",
                                                targetValues: [], duration: .allDay)
        let sugaryDrinksSchedule = OCKSchedule(composing: [sugaryDrinksElement])
        var sugaryDrinks = OCKTask(id: TaskID.sugaryDrinks,
                                   title: "Track sugary drinks 🥤",
                                   carePlanUUID: carePlanUUIDs[CarePlanID.diet],
                                   schedule: sugaryDrinksSchedule)
        sugaryDrinks.impactsAdherence = false
        // swiftlint:disable:next line_length
        sugaryDrinks.instructions = "Sugary drinks are unhealthy. Try to reduce your consumption by saving them for special occasions!"
        sugaryDrinks.asset = "soda.jpg"
        sugaryDrinks.card = .sugaryDrinks
        sugaryDrinks.graph = .line
        sugaryDrinks.groupIdentifier = "Drinks" // unit for data series legend

        let breakfastSchedule = OCKSchedule.dailyAtTime(hour: 5, minutes: 0,
                                                        start: Date(), end: nil,
                                                        text: "Eat Breakfast",
                                                        duration: .hours(6))
        var breakfast = OCKTask(id: TaskID.breakfast,
                                title: "Eat Breakfast 🍳",
                                carePlanUUID: carePlanUUIDs[CarePlanID.diet],
                                schedule: breakfastSchedule)
        breakfast.impactsAdherence = true
        breakfast.card = .simple
        breakfast.graph = .bar
        breakfast.groupIdentifier = "Breakfast Eaten" // unit for data series legend
        breakfast.instructions = "Start the day right, don't skip breakfast!"
        breakfast.asset = "avocado_toast.jpg"

        let stretchElement = OCKScheduleElement(start: beforeBreakfast,
                                                end: nil,
                                                interval: DateComponents(day: 1))
        let stretchSchedule = OCKSchedule(composing: [stretchElement])
        var stretch = OCKTask(id: TaskID.stretch,
                              title: "Get Up and Stretch 🕺",
                              carePlanUUID: carePlanUUIDs[CarePlanID.health],
                              schedule: stretchSchedule)
        stretch.impactsAdherence = true
        stretch.asset = "figure.walk"
        stretch.card = .instruction
        stretch.graph = .scatter
        stretch.groupIdentifier = "Stretches" // unit for data series legend
        stretch.instructions = "It's important to get up and stretch every once in a while"
        stretch.asset = "yoga.jpg"

        let pushupsElement = OCKScheduleElement(start: beforeBreakfast,
                                                end: nil,
                                                interval: DateComponents(day: 2),
                                                text: "10 Push-ups")
        let situpsElement = OCKScheduleElement(start: beforeBreakfast,
                                               end: nil,
                                               interval: DateComponents(day: 2),
                                               text: "25 Sit-ups")
        let squatsElement = OCKScheduleElement(start: beforeBreakfast,
                                               end: nil,
                                               interval: DateComponents(day: 2),
                                               text: "15 squats")
        let workoutSchedule = OCKSchedule(composing: [pushupsElement, situpsElement, squatsElement])
        var beginnerWorkout = OCKTask(id: TaskID.beginnerWorkout,
                                      title: "Beginner Workout 💪",
                                      carePlanUUID: carePlanUUIDs[CarePlanID.health],
                                      schedule: workoutSchedule)
        beginnerWorkout.card = .checklist
        // swiftlint:disable:next line_length
        beginnerWorkout.instructions = "An easy workout for beginners to do every 2 days. For more experienced users, create your own workout plan in the profile tab"
        beginnerWorkout.graph = .line
        beginnerWorkout.groupIdentifier = "Sets completed" // unit for data series legend
        beginnerWorkout.asset = "barbell.jpg"

        try await addTasksIfNotPresent([stretch, sugaryDrinks, breakfast, plan, diet,
                                        beginnerWorkout, water])
        try await addOnboardingTask(carePlanUUIDs[.health])
        try await addSurveyTasks(carePlanUUIDs[.checkIn])

        var contact1 = OCKContact(id: "jane",
                                  givenName: "Jane",
                                  familyName: "Daniels",
                                  carePlanUUID: carePlanUUIDs[.health])
        contact1.asset = "JaneDaniels"
        contact1.title = "Family Practice Doctor"
        contact1.role = "Dr. Daniels is a family practice doctor with 8 years of experience."
        contact1.emailAddresses = [OCKLabeledValue(label: CNLabelEmailiCloud, value: "janedaniels@uky.edu")]
        contact1.phoneNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(859) 257-2000")]
        contact1.messagingNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(859) 357-2040")]

        contact1.address = {
            let address = OCKPostalAddress()
            address.street = "2195 Harrodsburg Rd"
            address.city = "Lexington"
            address.state = "KY"
            address.postalCode = "40504"
            return address
        }()

        var contact2 = OCKContact(id: "matthew", givenName: "Matthew",
                                  familyName: "Reiff", carePlanUUID: carePlanUUIDs[.health])
        contact2.asset = "MatthewReiff"
        contact2.title = "OBGYN"
        contact2.role = "Dr. Reiff is an OBGYN with 13 years of experience."
        contact2.phoneNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(859) 257-1000")]
        contact2.messagingNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(859) 257-1234")]
        contact2.address = {
            let address = OCKPostalAddress()
            address.street = "1000 S Limestone"
            address.city = "Lexington"
            address.state = "KY"
            address.postalCode = "40536"
            return address
        }()

        try await addContactsIfNotPresent([contact1, contact2])
    }

    func addOnboardingTask(_ carePlanUUID: UUID? = nil) async throws {
        let onboardSchedule = OCKSchedule.dailyAtTime(
                    hour: 0, minutes: 0,
                    start: Date(), end: nil,
                    text: "Task Due!",
                    duration: .allDay
                )

        var onboardTask = OCKTask(
            id: Onboard.identifier(),
            title: "Onboard",
            carePlanUUID: carePlanUUID,
            schedule: onboardSchedule
        )
        onboardTask.instructions = "You'll need to agree to some terms and conditions before we get started!"
        onboardTask.impactsAdherence = false
        onboardTask.card = .survey
        onboardTask.survey = .onboard

        try await addTasksIfNotPresent([onboardTask])
    }

    func addSurveyTasks(_ carePlanUUID: UUID? = nil) async throws {
        let checkInSchedule = OCKSchedule.dailyAtTime(
            hour: 8, minutes: 0,
            start: Date(), end: nil,
            text: nil
        )

        var checkInTask = OCKTask(
            id: CheckIn.identifier(),
            title: "Check In 🎟️",
            carePlanUUID: carePlanUUID,
            schedule: checkInSchedule
        )
        checkInTask.card = .survey
        checkInTask.survey = .checkIn
        checkInTask.graph = .checkIn

        let thisMorning = Calendar.current.startOfDay(for: Date())

        let nextWeek = Calendar.current.date(
            byAdding: .weekOfYear,
            value: 1,
            to: Date()
        )!

        let nextMonth = Calendar.current.date(
            byAdding: .month,
            value: 1,
            to: thisMorning
        )

        let dailyElement = OCKScheduleElement(
            start: thisMorning,
            end: nextWeek,
            interval: DateComponents(day: 1),
            text: nil,
            targetValues: [],
            duration: .allDay
        )

        let weeklyElement = OCKScheduleElement(
            start: nextWeek,
            end: nextMonth,
            interval: DateComponents(weekOfYear: 1),
            text: nil,
            targetValues: [],
            duration: .allDay
        )

        let rangeOfMotionCheckSchedule = OCKSchedule(
            composing: [dailyElement, weeklyElement]
        )

        var rangeOfMotionTask = OCKTask(
            id: RangeOfMotion.identifier(),
            title: "Range Of Motion 🦿",
            carePlanUUID: carePlanUUID,
            schedule: rangeOfMotionCheckSchedule
        )
        rangeOfMotionTask.card = .survey
        rangeOfMotionTask.survey = .rangeOfMotion
        rangeOfMotionTask.graph = .bar
        rangeOfMotionTask.groupIdentifier = "Range (º)" // unit for data series legend

        try await addTasksIfNotPresent([checkInTask, rangeOfMotionTask])
    }
}
