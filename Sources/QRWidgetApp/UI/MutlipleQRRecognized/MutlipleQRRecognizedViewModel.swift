//
//  MutlipleQRRecognizedViewModel.swift
//  QRWidget
//
//  Created by Максим Казаков on 14.06.2022.
//

import SwiftUI
import Combine
import QRWidgetCore

class MutlipleQRRecognizedViewModel: ViewModel {
    let favoritesService: FavoritesService
    let qrCodesService: QRCodesService
    let items: [SingleCodeRowUIModel]
    let onClose: EmptyBlock

    init(favoritesService: FavoritesService, qrCodesService: QRCodesService, codes: [QRModel], onClose: @escaping EmptyBlock) {
        self.favoritesService = favoritesService
        self.qrCodesService = qrCodesService
        self.items = codes.map { SingleCodeRowUIModel(model: $0, isFavorite: false) }
        self.onClose = onClose
        super.init()
    }

    @ViewBuilder
    func detailsView(id: UUID) -> some View {
        if let model = qrCodesService.getQR(id: id) {
            generalAssembly.makeDetailsView(qrModel: model)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    func rowView(item: SingleCodeRowUIModel) -> some View {
        generalAssembly.makeSingleQRRowView(model: item)
    }
}
