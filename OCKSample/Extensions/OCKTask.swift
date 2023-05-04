//
//  OCKTask.swift
//  OCKSample
//
//  Created by  on 3/21/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore

extension OCKTask {

    /// The actual CareKit card for this task
    var card: CareKitCard {
        get {
            guard let cardInfo = userInfo?[Constants.card],
                  let careKitCard = CareKitCard(rawValue: cardInfo) else {
                return .grid // Default card if none was saved
            }
            return careKitCard // Saved card type
        }
        set {
            if userInfo == nil {
                // Initialize userInfo with empty dictionary
                userInfo = .init()
            }
            // Set the new card type
            userInfo?[Constants.card] = newValue.rawValue
        }
    }

    var survey: Survey {
        get {
            guard let surveyInfo = userInfo?[Constants.survey],
                  let surveyType = Survey(rawValue: surveyInfo) else {
                return .checkIn // Default survey if none was saved
            }
            return surveyType // Saved survey type
        }
        set {
            if userInfo == nil {
                // Initialize userInfo with empty dictionary
                userInfo = .init()
            }
            // Set the new card type
            userInfo?[Constants.survey] = newValue.rawValue
        }
    }

    var graph: GraphCard {
        get {
            guard let graphInfo = userInfo?[Constants.graph],
                  let graphType = GraphCard(rawValue: graphInfo) else {
                return .nausea // default graph CHANGE!!!
            }
            return graphType // Saved graph type
        }
        set {
            if userInfo == nil {
                // Initialize userInfo with empty dictionary
                userInfo = .init()
            }
            // Set the new card type
            userInfo?[Constants.graph] = newValue.rawValue
        }
    }
}
