//
//  PlanCardView.swift
//  OCKSample
//
//  Created by Corey Baker on 4/25/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//
import SwiftUI
import CareKitUI
import CareKitStore

struct PlanCardView: View {
    @Environment(\.careKitStyle) var style
    @StateObject var viewModel: PlanCardViewModel

    var body: some View {
        CardView {
            VStack(alignment: .leading,
                   spacing: style.dimension.directionalInsets1.top) {

                // Can look through HeaderView for creating custom
                HeaderView(title: Text(viewModel.taskEvents.firstEventTitle),
                           detail: Text(viewModel.taskEvents.firstEventDetail ?? ""))
                Divider()
                VStack {
                    Image("planner.jpg")
                        .resizable()
                        .frame(width: 325, height: 210, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    // swiftlint:disable:next line_length
                    Text("Not everyone can wake up and immediately be productive. Planning out your day can be a relaxing ritual and can provide surprisingly effective improvements to your day. Ready to start? Here are some resources to help: ")
                        .font(.body)
                        .padding()
                    Link("Visit WikiHow",
                         destination: URL(string: "https://www.wikihow.com/Schedule-Your-Day")!)
                        .font(.title2)
                        .padding()
                    Link("Visit Indeed",
                    // swiftlint:disable:next line_length
                         destination: URL(string: "https://www.indeed.com/career-advice/career-development/day-planning")!)
                        .font(.title2)
                        .padding()
                    Link("Visit todoist",
                         destination: URL(string: "https://todoist.com/inspiration/how-to-plan-your-day")!)
                        .font(.title2)
                        .padding()

                }
            }
            .padding()
        }
        .onReceive(viewModel.$taskEvents) { taskEvents in
            /*
             DO NOT CHANGE THIS. The viewModel needs help
             from view to update "value" since taskEvents
             can't be overriden in viewModel.
             */
            viewModel.checkIfValueShouldUpdate(taskEvents)
        }
        .onReceive(viewModel.$error) { error in
            /*
             DO NOT CHANGE THIS. The viewModel needs help
             from view to update "currentError" since taskEvents
             can't be overriden in viewModel.
             */
            viewModel.setError(error)
        }
    }
}

struct PlanCardView_Previews: PreviewProvider {
    static var previews: some View {
        PlanCardView(viewModel: .init(storeManager: .init(wrapping: OCKStore(name: Constants.noCareStoreName,
                                                                               type: .inMemory))))
    }
}
