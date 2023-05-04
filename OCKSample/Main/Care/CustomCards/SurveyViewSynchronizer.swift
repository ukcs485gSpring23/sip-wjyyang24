//
//  SurveyViewSynchronizer.swift
//  OCKSample
//
//  Created by Corey Baker on 4/14/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//
import CareKit
import CareKitStore
import CareKitUI
import ResearchKit
import UIKit
import os.log

final class SurveyViewSynchronizer: OCKSurveyTaskViewSynchronizer {

    override func updateView(_ view: OCKInstructionsTaskView,
                             context: OCKSynchronizationContext<OCKTaskEvents>) {

        super.updateView(view, context: context)

        if let event = context.viewModel.first?.first, event.outcome != nil,
           let surveyTask = event.task as? OCKTask {
            view.instructionsLabel.isHidden = false
            switch surveyTask.title {
            case "Check In 🎟️":
                let restfulness = event.answer(kind: CheckIn.restItemIdentifier)
                let sleep = event.answer(kind: CheckIn.sleepItemIdentifier)

                view.instructionsLabel.text = """
                Restfulness: \(Int(restfulness))
                Sleep: \(Int(sleep)) hours
                """
            case "Range of Motion 🦿":
                let range = event.answer(kind: #keyPath(ORKRangeOfMotionResult.range))

                view.instructionsLabel.text = """
                Range of Motion: \(range)º
                """
            default:
                view.instructionsLabel.isHidden = true
            }
        } else {
            view.instructionsLabel.isHidden = true
        }
    }
}
