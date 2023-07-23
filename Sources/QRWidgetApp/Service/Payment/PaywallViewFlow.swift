
import SwiftUI

struct PaywallViewFlow: View {
    
    @StateObject var viewModel: PaywallViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Group {
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
