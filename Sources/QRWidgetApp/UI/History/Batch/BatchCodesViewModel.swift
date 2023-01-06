//
//  BatchHistoryViewModel.swift
//  QRWidget
//
//  Created by Максим Казаков on 15.06.2022.
//

import Foundation
import SwiftUI
import QRWidgetCore

class BatchCodesViewModel: ViewModel {

    private let batchId: UUID
    private let qrCodesRepository: QRCodesRepository
    private let favoritesService: FavoritesService
    private var isAppeared = false

    init(batchId: UUID, qrCodesRepository: QRCodesRepository, favoritesService: FavoritesService) {
        self.batchId = batchId
        self.qrCodesRepository = qrCodesRepository
        self.favoritesService = favoritesService
        super.init()
    }

    // MARK: - HistoryViewModelProtocol
    @Published var codes: [SingleCodeRowUIModel] = []
    @Published var isLoading = false

    var title: String {
        "Batch"
    }

    func remove(_ indexSet: IndexSet) {
        var codesIds: Set<UUID> = []
        for index in indexSet {
            codesIds.insert(codes[index].id)
        }
        qrCodesRepository.remove(ids: codesIds)
    }

    func onAppear() {
        guard !isAppeared else { return }
        isAppeared = true
        qrCodesRepository.qrCodesPublisher
            .sink(receiveValue: { [weak self] in
                self?.makeUIModels(from: $0)
            })
            .store(in: &cancellableSet)
    }


    @ViewBuilder
    func singleDetailsView(id: UUID) -> some View {
        if let model = qrCodesRepository.get(id: id) {
            generalAssembly.makeDetailsView(qrModel: model)
        } else {
            EmptyView()
        }
    }

    func rowView(item: SingleCodeRowUIModel) -> some View {
        generalAssembly.makeSingleQRRowView(model: item)
    }

    // MARK: - Private

    func isInFavorite(_ id: UUID) -> Bool {
        favoritesService.isFavorite(qrId: id)
    }

    private func makeUIModels(from codes: [QRModel]) {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let sortedCodes = codes                
                .filter { $0.batchId == self.batchId }
                .map { SingleCodeRowUIModel(model: $0, isFavorite: self.isInFavorite($0.id)) }

            DispatchQueue.main.async {
                self.isLoading = false
                self.codes = sortedCodes
            }
        }
    }
}
