//
//  BatchHistoryViewModel.swift
//  QRWidget
//
//  Created by Максим Казаков on 15.06.2022.
//

import Foundation
import SwiftUI
import QRWidgetCore

class BatchCodesViewModel: ViewModel, HistoryViewModelProtocol {

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
    @Published var sections: [HistorySectionUIModel] = []
    @Published var isLoading = false

    var title: String {
        "Batch"
    }

    func remove(_ indexSet: IndexSet, section: HistorySectionUIModel) {
        var codesIds: Set<UUID> = []
        for index in indexSet {
            let item = section.items[index].data
            switch item {
            case let .single(single):
                codesIds.insert(single.id)

            case let .multiple(multiple):
                for itemFromMultiple in multiple.codes {
                    codesIds.insert(itemFromMultiple.id)
                }
            }
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

    func mutlipleDetailsView(batchId: UUID) -> some View {
        EmptyView()
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
                .sorted(by: { $0.dateCreated > $1.dateCreated })
                .filter { $0.batchId == self.batchId }
                .map { HistoryItemUIModel(data: .single(SingleCodeRowUIModel(model: $0, isFavorite: self.isInFavorite($0.id)))) }

            var sections: [HistorySectionUIModel] = []
            if let firstCode = sortedCodes.first {
                let day = Calendar.current.numberOfDaysBetween(firstCode.date, and: Date(timeIntervalSince1970: 0))
                let formattedDate = FormatsHelper.formatDay(firstCode.date)
                sections.append(HistorySectionUIModel(day: day, formattedDate: formattedDate, items: sortedCodes))
            }

            DispatchQueue.main.async {
                self.isLoading = false
                self.sections = sections
            }
        }
    }
}
