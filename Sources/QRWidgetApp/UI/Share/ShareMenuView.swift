
import SwiftUI
import QRWidgetCore

struct ShareMenuView: View {
    let qrModel: CodeModel
    @StateObject var viewModel: ShareMenuViewModel

    var body: some View {
        if qrModel.data.stringPayload != nil {
            Menu {
                Button(L10n.Sharing.asImage, action: { viewModel.shareAsImage(qrModel) })
                Button(L10n.Sharing.asText, action: { viewModel.shareAsText(qrModel) })
            } label: {
                button
            }
            .onTapGesture {
                viewModel.trackTapShare()
            }
        } else {
            Button(
                action: {
                    viewModel.shareAsImage(qrModel)
                    viewModel.trackTapShare()
                },
                label: {
                    button
                }
            )
        }
    }

    @ViewBuilder
    var button: some View {
        defaultButton
    }

    @ViewBuilder
    var defaultButton: some View {
        Label(L10n.Sharing.title, systemImage: "square.and.arrow.up")
            .foregroundColor(Color.primaryColor)
    }
}
