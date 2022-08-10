//
//  HistoryMultipleRowView.swift
//  QRWidget
//
//  Created by Максим Казаков on 14.06.2022.
//

import SwiftUI

struct HistoryMultipleRowView: View {

    let model: HistoryMultipleCodesUIModel

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "folder")
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.History.batch)
                        .multilineTextAlignment(.leading)
                        .font(.body)
                Text(L10n.History.Batch.countOfCodes(model.codes.count))
                        .multilineTextAlignment(.leading)
                        .font(.callout)
            }
        }

    }
}
