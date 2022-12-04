//
//  SingleCodeRow.swift
//  QRWidget
//
//  Created by Максим Казаков on 15.06.2022.
//

import SwiftUI

struct SingleCodeRowView: View {

    let model: SingleCodeRowUIModel
    @StateObject var viewModel: SingleCodeRowViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "qrcode")
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
        }
    }
}
