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

//struct SingleCodeRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        SingleCodeRowView(viewModel: SingleCodeRowUIModel(id: UUID(),
//                                                             label: "Yandex Media",
//                                                             qrData: .rawText("https://music.yandex.ru/home"), isFavorite: false, date: Date()))
//        .padding(.all, 20)
//    }
//}
