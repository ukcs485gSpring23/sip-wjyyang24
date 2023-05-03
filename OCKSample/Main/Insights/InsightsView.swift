//
//  InsightsView.swift
//  OCKSample
//
//  Created by  on 4/20/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct InsightsView: UIViewControllerRepresentable {
    @State var storeManager = StoreManagerKey.defaultValue

    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = InsightsViewController(storeManager: storeManager)
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType,
                                context: Context) {}
}

struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        InsightsView()
    }
}
