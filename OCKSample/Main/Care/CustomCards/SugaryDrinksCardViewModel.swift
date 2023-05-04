//
//  SugaryDrinksCardViewModel.swift
//  OCKSample
//
//  Created by Corey Baker on 4/25/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//
import CareKit
import CareKitStore
import Foundation

class SugaryDrinksCardViewModel: CardViewModel {

    let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.zeroSymbol = ""
        return formatter
    }()

    /// This value can be used directly in Text() views.
    var valueAsInt: Int {
        get {
            guard let intValue = value?.integerValue else {
                return 0
            }
            return intValue
        }
        set {
            value = OCKOutcomeValue(newValue)
        }
    }
}
