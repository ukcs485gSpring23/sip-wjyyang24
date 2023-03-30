//
//  CareKitTaskView.swift
//  OCKSample
//
//  Created by  on 3/21/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct CareKitTaskView: View {
    @StateObject var viewModel = CareKitTaskViewModel()

    var body: some View {
        NavigationView {
            Form {
                TextField("Title",
                          text: $viewModel.title)
                TextField("Instructions",
                          text: $viewModel.instructions)
                Picker("Card View", selection: $viewModel.selectedCard) {
                    ForEach(CareKitCard.allCases) { item in
                        Text(item.rawValue)
                    }
                }
                DatePicker("Time", selection: $viewModel.hourAndMinute, displayedComponents: .hourAndMinute)
                DatePicker("Start Date", selection: $viewModel.startDate, displayedComponents: .date)
                // DatePicker("End Date", selection: $viewModel.endDate, displayedComponents: .date)
                Section("Task") {
                    Button("Add") {
                        Task {
                            await viewModel.addTask()
                        }
                    }
                }
                Section("HealthKitTask") {
                    Button("Add") {
                        Task {
                            await viewModel.addHealthKitTask()
                        }
                    }
                }
            }
        }
    }
}

struct CareKitTaskView_Previews: PreviewProvider {
    static var previews: some View {
        CareKitTaskView()
    }
}
