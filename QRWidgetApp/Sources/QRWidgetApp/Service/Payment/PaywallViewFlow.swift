//
//  PaywallViewConnector.swift
//  QRWidget
//
//  Created by Максим Казаков on 26.10.2021.
//

import SwiftUI

struct PaywallViewFlow: View {
    
    @StateObject var viewModel: PaywallViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Group {
            let _ = print("payment state: \(viewModel.state)")
            switch viewModel.state {
            case .data, .loading, .error:
                PaywallScreen(viewModel: viewModel)

            case .succeed:
                SubscriptionAcivatedView(onContinue: { viewModel.close() })
            }
        }
        .onChange(of: viewModel.needToClose, perform: {
            if $0 {
                presentationMode.wrappedValue.dismiss()
            }
        })
        .onAppear(perform: {
            viewModel.onAppear()
        })
    }
}
