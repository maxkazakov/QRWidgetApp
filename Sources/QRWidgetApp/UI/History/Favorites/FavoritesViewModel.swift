
import Combine
import SwiftUI
import QRWidgetCore

class FavoritesViewModel: ViewModel {

    private let qrCodesService: QRCodesService
    private let favoritesSerice: FavoritesService

    init(qrCodesService: QRCodesService, favoritesSerice: FavoritesService) {
        self.qrCodesService = qrCodesService
        self.favoritesSerice = favoritesSerice
        super.init()

        Publishers.CombineLatest(qrCodesService.favoriteQrCodes, $isProActivated)
            .sink(receiveValue: { [weak self] qrCodes, isProActivated in
                self?.updateQrCodeList(qrCodes, isProActivated: isProActivated)
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

    func remove(_ indexSet: IndexSet) {        
        for index in indexSet {
            favoritesSerice.removeFavorite(id: codes[index].id)
        }
    }

    func rowView(item: SingleCodeRowUIModel) -> some View {
        generalAssembly.makeSingleQRRowView(model: item)
    }

    @Published var showNeedToPaySubscription = false
    @Published var codes: [SingleCodeRowUIModel] = []

    // MARK: - Private

    private func updateQrCodeList(_ qrCodes: [QRModel], isProActivated: Bool) {
        if qrCodes.count > 1, !isProActivated {
            let firstQrCode = qrCodes.first!
            self.codes = [SingleCodeRowUIModel(model: firstQrCode, isFavorite: true)]
            self.showNeedToPaySubscription = true
        } else {
            self.showNeedToPaySubscription = false
            self.codes = qrCodes.map {
                SingleCodeRowUIModel(model: $0, isFavorite: true)
            }
        }
    }
}

extension UUID {
    static let zero = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
}


