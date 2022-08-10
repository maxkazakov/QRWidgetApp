//
//  AddToWalletButton.swift
//  QRWidget
//
//  Created by Максим Казаков on 29.10.2021.
//

import SwiftUI
import PassKit
import QRWidgetCore

struct AddToWalletButton: View {

    let qrModel: QRModel
    @StateObject var viewModel: AddToWalletButtonViewModel
    @State var showPaywall: Bool = false

    var body: some View {
        VStack(spacing: 12) {
            if viewModel.hasWalletPass {
                Text(L10n.AppleWallet.qrAlreadyAdded)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }
            
            if viewModel.status == .loading {
                ProgressView(L10n.AppleWallet.progress)
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                if PKPassLibrary.isPassLibraryAvailable(), PKAddPassesViewController.canAddPasses() {
                    PassButton(onClick: {
                        if viewModel.isProActivated {
                            viewModel.generatePass(qrModel: qrModel)
                        } else {
                            showPaywall = true
                        }
                    })
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 44)
                } else {
                    EmptyView()
                }
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            generalAssembly.makePaywallView(sourceScreen: .appleWallet)
        }
        .sheet(isPresented: $viewModel.presentGeneratedPass, content: {
            PKAddPassesView(pass: viewModel.pass!, onFinish: { viewModel.finish(qrModel: qrModel) })
        })
        .alert(isPresented: $viewModel.presentErrorAlert, content: {
            Alert(
                title: Text(L10n.AppleWallet.failedToCreatePass),
                message: Text(L10n.AppleWallet.tryAgain),
                dismissButton: nil
            )
        })
        .onAppear(perform: {
            viewModel.checkHasPass(qrModel: qrModel)
        })
    }
}
