//
//  OCKHealthKitTask.swift
//  OCKSample
//
//  Created by Wesley Yang on 3/23/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore

extension OCKHealthKitTask {
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

    var graph: GraphCard {
        get {
            guard let graphInfo = userInfo?[Constants.graph],
                  let graphType = GraphCard(rawValue: graphInfo) else {
                return .bar
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
