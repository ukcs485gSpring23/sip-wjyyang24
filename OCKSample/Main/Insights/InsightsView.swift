//
//  InsightsView.swift
//  OCKSample
//
//  Created by  on 4/20/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct InsightsView: View {
    @StateObject var viewModel = InsightsViewModel()

    var body: some View {
        Text(viewModel.text)
    }
}

struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        InsightsView()
    }
}
