import SwiftUI

struct SingleCodeRowView: View {

    let model: SingleCodeRowUIModel
    @StateObject var viewModel: SingleCodeRowViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            switch model.codeType {
            case .aztec:
                VStack {
                    Image(systemName: "barcode")
                    Text("aztec")
                        .font(.caption)
                }
            case .code128, .code39, .ean13, .ean8, .code39Mod43:
                VStack {
                    Image(systemName: "barcode")
                    Text("barcode")
                        .font(.caption)
                }
            case .qr:
                Image(systemName: "qrcode")
            case .pdf417:
                VStack {
                    Image(systemName: "barcode")
                    Text("pdf417")
                        .font(.caption)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                if !model.label.isEmpty {
                    Text(model.label)
                        .multilineTextAlignment(.leading)
                        .font(.body)
                }

                QRCodeView(codeContent: model.qrData, isDetailed: false)
                    .allowsHitTesting(false)
            }
            if viewModel.isFavorite {
                Image(systemName: "star.fill")
                    .imageScale(.small)
                    .foregroundColor(Color.yellow)
            }

            if model.isMy {
                Image(systemName: "person.crop.circle.fill")
                    .imageScale(.small)
                    .foregroundColor(Color.green)
            }
        }
    }
}

import QRWidgetCore

struct SingleCodeRowView_Previews: PreviewProvider {
    static var previews: some View {
        SingleCodeRowView(
            model: SingleCodeRowUIModel(
                model: CodeModel(data: .string("something"), type: .aztec, qrStyle: nil),
                isFavorite: false
            ),
            viewModel: SingleCodeRowViewModel(id: UUID(), favoritesService: FavoritesService())
        )

    }
}
