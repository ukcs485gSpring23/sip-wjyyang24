//
//  CustomCardViewModel.swift
//  OCKSample
//
//  Created by Corey Baker on 4/25/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//
import CareKit
import CareKitStore
import Foundation

class CustomCardViewModel: CardViewModel {
    /*
     TODOx: Place any additional properties needed for your custom Card.
     Be sure to @Published them if they update your view
     */

    let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.zeroSymbol = ""
        return formatter
    }()

    /// This value can be used directly in Text() views.
    var valueAsDouble: Double {
        get {
            guard let doubleValue = value?.doubleValue else {
                return 0.0
            }
            return doubleValue
        }
        set {
            value = OCKOutcomeValue(newValue)
        }
    }
}
