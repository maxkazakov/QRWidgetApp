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
            case .qr:
                Image(systemName: "qrcode")
            }

            VStack(alignment: .leading, spacing: 8) {
                if !model.label.isEmpty {
                    Text(model.label)
                        .multilineTextAlignment(.leading)
                        .font(.body)
                }

                QRCodeView(type: model.qrData)
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
                model: CodeModel.init(data: .string("something"), type: .aztec),
                isFavorite: false
            ),
            viewModel: SingleCodeRowViewModel(id: UUID(), favoritesService: FavoritesService())
        )

    }
}
