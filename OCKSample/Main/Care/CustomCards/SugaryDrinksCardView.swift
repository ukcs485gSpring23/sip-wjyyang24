//
//  SugaryDrinksCardView.swift
//  OCKSample
//
//  Created by Corey Baker on 4/25/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//
import SwiftUI
import CareKitUI
import CareKitStore

// swiftlint:disable multiple_closures_with_trailing_closure
struct SugaryDrinksCardView: View {
    @Environment(\.careKitStyle) var style
    @StateObject var viewModel: SugaryDrinksCardViewModel

    var body: some View {
        CardView {
            VStack(alignment: .leading,
                   spacing: style.dimension.directionalInsets1.top) {

                // Can look through HeaderView for creating custom
                HeaderView(title: Text(viewModel.taskEvents.firstEventTitle),
                           detail: Text(viewModel.taskEvents.firstEventDetail ?? ""))
                VStack {
                    Image("soda.jpg")
                        .resizable()
                        .frame(width: 325, height: 210, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Divider()
                HStack(alignment: .center,
                       spacing: style.dimension.directionalInsets2.trailing) {

                    Button(action: {
                        Task {
                            await viewModel.action(viewModel.value)
                        }
                    }) {
                        CircularCompletionView(isComplete: viewModel.taskEvents.isFirstEventComplete) {
                            Image(systemName: "checkmark") // Can place any view type here
                                .resizable()
                                .padding()
                                .frame(width: 50, height: 50) // Change size to make larger/smaller
                        }
                    }
                    Spacer()

                    Text("Drinks: ")
                        .font(Font.headline)
                    TextField("0",
                              value: $viewModel.valueAsInt,
                              formatter: viewModel.amountFormatter)
                        .keyboardType(.decimalPad)
                        .font(Font.title.weight(.bold))
                        .foregroundColor(.accentColor)

                    Spacer()
                    Button(action: {
                        Task {
                            await viewModel.action(viewModel.value)
                        }
                    }) {
                        RectangularCompletionView(isComplete: viewModel.taskEvents.isFirstEventComplete) {
                            Image(systemName: "checkmark") // Can place any view type here
                                .resizable()
                                .padding()
                                .frame(width: 50, height: 50) // Change size to make larger/smaller
                        }
                    }

                    (viewModel.valueText ?? Text("0"))
                        .multilineTextAlignment(.trailing)
                        .font(Font.title.weight(.bold))
                        .foregroundColor(.accentColor)
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

struct SugaryDrinksCardView_Previews: PreviewProvider {
    static var previews: some View {
        SugaryDrinksCardView(viewModel: .init(storeManager: .init(wrapping: OCKStore(name: Constants.noCareStoreName,
                                                                               type: .inMemory))))
    }
}
