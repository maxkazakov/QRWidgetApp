
import Foundation
import SwiftUI
import QRWidgetCore
import XCTestDynamicOverlay

class HistoryViewModel: ViewModel {

    private let qrCodesService: QRCodesService
    private let favoritesService: FavoritesService
    private var isAppeared = false

    init(qrCodesService: QRCodesService, favoritesService: FavoritesService) {
        self.qrCodesService = qrCodesService
        self.favoritesService = favoritesService
        super.init()
    }

    var startScanningTapped: EmptyBlock = unimplemented("HistoryViewModel.startScanningTapped")

    // MARK: - HistoryViewModelProtocol
    @Published var sections: [HistorySectionUIModel] = []
    @Published var isLoading = false

    func remove(_ indexSet: IndexSet, section: HistorySectionUIModel) {
        for index in indexSet {
            let item = section.items[index].data
            switch item {
            case let .single(single):
                qrCodesService.removeQR(id: single.id)

            case let .multiple(multiple):
                for itemFromMultiple in multiple.codes {
                    qrCodesService.removeQR(id: itemFromMultiple.id)
                }
            }
        }
    }

    func onAppear() {
        guard !isAppeared else { return }
        isAppeared = true
        qrCodesService.qrCodesPublisher
            .sink(receiveValue: { [weak self] in
                self?.makeUIModels(from: $0)
            })
            .store(in: &cancellableSet)
    }


    @ViewBuilder
    func singleDetailsView(id: UUID) -> some View {
        if let model = qrCodesService.getQR(id: id) {
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
                .filter { !$0.isMy }
                .sorted { $0.dateCreated > $1.dateCreated }
            
            var sections = [HistorySectionUIModel]()
            var i = 0
            while i < sortedCodes.count {
                let code = sortedCodes[i]
                let day = Calendar.current.numberOfDaysBetween(code.dateCreated, and: Date(timeIntervalSince1970: 0))
                if sections.last?.day != day {
                    let newSection = HistorySectionUIModel(
                        day: day,
                        formattedDate: FormatsHelper.formatDay(code.dateCreated),
                        items: []
                    )
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
