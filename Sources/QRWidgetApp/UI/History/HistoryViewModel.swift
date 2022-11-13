//
//  HistoryViewModel.swift
//  QRWidget
//
//  Created by Максим Казаков on 16.04.2022.
//

import Foundation
import SwiftUI
import QRWidgetCore

protocol HistoryViewModelProtocol: ViewModelProtocol {
    associatedtype SingleDetailsView: View
    associatedtype MultipleDetailsView: View
    associatedtype SingleRowView: View

    var title: String { get }
    var sections: [HistorySectionUIModel] { get }

    func onAppear()
    func singleDetailsView(id: UUID) -> SingleDetailsView
    func mutlipleDetailsView(batchId: UUID) -> MultipleDetailsView
    func rowView(item: SingleCodeRowUIModel) -> SingleRowView
    func remove(_ indexSet: IndexSet, section: HistorySectionUIModel)
}


class HistoryViewModel: ViewModel, HistoryViewModelProtocol {

    private let qrCodesRepository: QRCodesRepository
    private let favoritesService: FavoritesService
    private var isAppeared = false

    init(qrCodesRepository: QRCodesRepository, favoritesService: FavoritesService) {
        self.qrCodesRepository = qrCodesRepository
        self.favoritesService = favoritesService
        super.init()
    }

    // MARK: - HistoryViewModelProtocol
    @Published var sections: [HistorySectionUIModel] = []
    @Published var isLoading = false

    var title: String {
        L10n.History.title
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
        generalAssembly.makeBatchCodesView(batchId: batchId)
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

            var sections = [HistorySectionUIModel]()
            var i = 0
            while i < sortedCodes.count {
                let code = sortedCodes[i]
                let day = Calendar.current.numberOfDaysBetween(code.dateCreated, and: Date(timeIntervalSince1970: 0))
                if sections.last?.day != day {
                    let newSection = HistorySectionUIModel(day: day,
                                                           formattedDate: FormatsHelper.formatDay(code.dateCreated),
                                                           items: [])
                    sections.append(newSection)
                }

                let item: HistoryItemUIModel
                if let batchId = code.batchId {
                    var j = i
                    var multiple = HistoryMultipleCodesUIModel(batchId: batchId, codes: [])
                    while j < sortedCodes.count && sortedCodes[j].batchId == code.batchId {
                        let codeInBatch = sortedCodes[j]
                        let single = SingleCodeRowUIModel(model: codeInBatch, isFavorite: self.isInFavorite(codeInBatch.id))
                        multiple.codes.append(single)
                        j += 1
                    }
                    item = HistoryItemUIModel(data: .multiple(multiple))
                    i = j
                } else {
                    let single = SingleCodeRowUIModel(model: code, isFavorite: self.isInFavorite(code.id))
                    item = HistoryItemUIModel(data: .single(single))
                    i += 1
                }
                sections.indices.last.map { sections[$0].items.append(item) }
            }

            DispatchQueue.main.async {
                self.isLoading = false
                self.sections = sections
            }
        }
    }
}

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        return numberOfDays.day!
    }
}
