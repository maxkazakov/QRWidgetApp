//
//  ShareMenu.swift
//  QRWidget
//
//  Created by Максим Казаков on 23.04.2022.
//

import SwiftUI
import QRWidgetCore

struct ShareMenuView: View {    
    let qrModel: CodeModel
    var customButton: (() -> AnyView)? = nil
    @StateObject var viewModel: ShareMenuViewModel

    var body: some View {
        Menu {
            Button(L10n.Sharing.asImage, action: { viewModel.shareAsImage(qrModel) })
            Button(L10n.Sharing.asText, action: { viewModel.shareAsText(qrModel) })
        } label: {
            button
        }
        .onTapGesture {
            viewModel.trackTapShare()
        }
    }

    @ViewBuilder
    var button: some View {
        if let custom = customButton?() {
            custom
        } else {
            defaultButton
        }
    }

    @ViewBuilder
    var defaultButton: some View {
        Label(L10n.Sharing.title, systemImage: "square.and.arrow.up")
            .foregroundColor(Color.primaryColor)
    }
}
