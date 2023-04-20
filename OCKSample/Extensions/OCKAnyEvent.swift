//
//  OCKAnyEvent.swift
//  OCKSample
//
//  Created by Corey Baker on 4/14/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//
import CareKitStore

extension OCKAnyEvent {

    func answer(kind: String) -> Double {
        let values = outcome?.values ?? []
        let match = values.first(where: { $0.kind == kind })
        return match?.doubleValue ?? 0
    }
}
