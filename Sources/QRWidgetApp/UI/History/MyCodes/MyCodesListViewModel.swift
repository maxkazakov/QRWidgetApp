import Combine
import SwiftUI
import QRWidgetCore
import XCTestDynamicOverlay

class MyCodesListViewModel: ViewModel {

    private let qrCodesService: QRCodesService

    @Published var codes: [SingleCodeRowUIModel] = []

    var createNewTapped: EmptyBlock = unimplemented("MyCodesListViewModel.createNewTapped")

    init(qrCodesService: QRCodesService) {
        self.qrCodesService = qrCodesService
        super.init()

        qrCodesService.qrCodesPublisher
            .sink(receiveValue: { [weak self] qrCodes in
                self?.updateQrCodeList(qrCodes)
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
            qrCodesService.removeQR(id: codes[index].id)
        }
    }

    func rowView(item: SingleCodeRowUIModel) -> some View {
        generalAssembly.makeSingleQRRowView(model: item)
    }

    // MARK: - Private

    private func updateQrCodeList(_ qrCodes: [QRModel]) {
        self.codes = qrCodes
            .filter { $0.isMy }
            .map {
                SingleCodeRowUIModel(model: $0, isFavorite: true)
            }
    }
}


