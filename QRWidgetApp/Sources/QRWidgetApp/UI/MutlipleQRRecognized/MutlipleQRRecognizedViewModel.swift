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
    let qrCodesRepository: QRCodesRepository
    let items: [SingleCodeRowUIModel]
    let onClose: EmptyBlock

    init(favoritesService: FavoritesService, qrCodesRepository: QRCodesRepository, codes: [QRModel], onClose: @escaping EmptyBlock) {
        self.favoritesService = favoritesService
        self.qrCodesRepository = qrCodesRepository
        self.items = codes.map { SingleCodeRowUIModel(model: $0, isFavorite: false) }
        self.onClose = onClose
        super.init()
    }

    @ViewBuilder
    func detailsView(id: UUID) -> some View {
        if let model = qrCodesRepository.get(id: id) {
            generalAssembly.makeDetailsView(qrModel: model)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    func rowView(item: SingleCodeRowUIModel) -> some View {
        SingleCodeRowView(viewModel: SingleCodeRowViewModel(model: item, favoritesService: self.favoritesService))
    }
}
