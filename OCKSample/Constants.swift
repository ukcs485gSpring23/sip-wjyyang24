//
//  Constants.swift
//  OCKSample
//
//  Created by Corey Baker on 11/27/20.
//  Copyright © 2020 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKit
import CareKitStore
import ParseSwift

/**
 Set to **true** to sync with ParseServer, *false** to sync with iOS/watchOS.
 */
let isSyncingWithCloud = true
/**
 Set to **true** to use WCSession to notify watchOS about updates, **false** to not notify.
 A change in watchOS 9 removes the ability to use Websockets on real Apple Watches,
 preventing auto updates from the Parse Server. See the link for
 details: https://developer.apple.com/forums/thread/715024
 */
let isSendingPushUpdatesToWatch = true

enum AppError: Error {
    case couldntCast
    case couldntBeUnwrapped
    case valueNotFoundInUserInfo
    case remoteClockIDNotAvailable
    case emptyTaskEvents
    case invalidIndexPath(_ indexPath: IndexPath)
    case noOutcomeValueForEvent(_ event: OCKAnyEvent, index: Int)
    case cannotMakeOutcomeFor(_ event: OCKAnyEvent)
    case parseError(_ error: ParseError)
    case error(_ error: Error)
    case errorString(_ string: String)
}

extension AppError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .couldntCast:
            return NSLocalizedString("OCKSampleError: Could not cast to required type.",
                                     comment: "Casting error")
        case .couldntBeUnwrapped:
            return NSLocalizedString("OCKSampleError: Could not unwrap a required type.",
                                     comment: "Unwrapping error")
        case .valueNotFoundInUserInfo:
            return NSLocalizedString("OCKSampleError: Could not find the required value in userInfo.",
                                     comment: "Value not found error")
        case .remoteClockIDNotAvailable:
            return NSLocalizedString("OCKSampleError: Could not get remote clock ID.",
                                     comment: "Value not available error")
        case .emptyTaskEvents: return "Task events is empty"
        case let .noOutcomeValueForEvent(event, index): return "Event has no outcome value at index \(index): \(event)"
        case .invalidIndexPath(let indexPath): return "Invalid index path \(indexPath)"
        case .cannotMakeOutcomeFor(let event): return "Cannot make outcome for event: \(event)"
        case .parseError(let error): return "\(error)"
        case .error(let error): return "\(error)"
        case .errorString(let string): return string
        }
    }
}

enum Constants {
    static let parseConfigFileName = "ParseCareKit"
    static let iOSParseCareStoreName = "iOSParseStore"
    static let iOSLocalCareStoreName = "iOSLocalStore"
    static let watchOSParseCareStoreName = "watchOSParseStore"
    static let watchOSLocalCareStoreName = "watchOSLocalStore"
    static let noCareStoreName = "none"
    static let parseUserSessionTokenKey = "requestParseSessionToken"
    static let requestSync = "requestSync"
    static let progressUpdate = "progressUpdate"
    static let finishedAskingForPermission = "finishedAskingForPermission"
    static let shouldRefreshView = "shouldRefreshView"
    static let userLoggedIn = "userLoggedIn"
    static let storeInitialized = "storeInitialized"
    static let userTypeKey = "userType"
    static let card = "card"
    static let survey = "survey"
    static let graph = "graph"
}

enum MainViewPath {
    case tabs
}

enum CareKitCard: String, CaseIterable, Identifiable {
    var id: Self { self }
    case button = "Button"
    case checklist = "Checklist"
    case featured = "Featured"
    case grid = "Grid"
    case instruction = "Instruction"
    case labeledValue = "Labeled Value"
    case link = "Link"
    case numericProgress = "Numeric Progress"
    case simple = "Simple"
    case survey = "Survey"
    case plan = "Plan"
    case sugaryDrinks = "Sugary Drinks"
}

enum GraphCard: String, CaseIterable, Identifiable {
    var id: Self { self }
//    case nausea = "Nausea"
    case checkIn = "Check In"
    case bar = "Bar"
    case line = "Line"
    case scatter = "Scatter"
}

enum CarePlanID: String, CaseIterable, Identifiable {
    var id: Self { self }
    case health = "Health"
    case checkIn = "Check In"
    case productivity = "Productivity"
    case diet = "Diet"
}

enum TaskID {
    static let stretch = "stretch"
    static let steps = "steps"
    static let plan = "plan"
    static let water = "water"
    static let flightsClimbed = "flights climbed"
    static let breakfast = "breakfast"
    static let beginnerWorkout = "beginner workout"
    static let diet = "diet"
    static let sugaryDrinks = "sugary drinks"
    static let heartRate = "heart rate"

    static var ordered: [String] {
        [Self.steps, Self.plan, Self.stretch, Self.water, Self.flightsClimbed, Self.breakfast,
         Self.heartRate, Self.beginnerWorkout, Self.diet, Self.sugaryDrinks]
    }
}

enum UserType: String, Codable {
    case patient                           = "Patient"
    case none                              = "None"

    // Return all types as an array, make sure to maintain order above
    func allTypesAsArray() -> [String] {
        return [UserType.patient.rawValue,
                UserType.none.rawValue]
    }
}

enum InstallationChannel: String {
    case global
}
