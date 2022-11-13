//
//  PagesNavigator.swift
//  QRWidget
//
//  Created by Максим Казаков on 30.10.2021.
//

import Combine
import SwiftUI
import QRWidgetCore

class QRPagesViewModel: ViewModel {

    private let qrCodesService: QRCodesService
    private let storage: UserDefaultsStorage

    init(qrCodesService: QRCodesService, storage: UserDefaultsStorage) {
        self.qrCodesService = qrCodesService
        self.storage = storage
        super.init()

        Publishers.CombineLatest(qrCodesService.favoriteQrCodes, $isProActivated)
            .sink(receiveValue: { [weak self] qrCodes, isProActivated in
                self?.updateQrCodeList(qrCodes, isProActivated: isProActivated)
            })
            .store(in: &cancellableSet)
    }


    @Published var showFlipTip = false
    @Published var showNeedToPaySubscription = false
    @Published var qrCodesList: [QRModel] = []

    // This selectedQr updates randomly when list of QR codes is being updated
    @Published var selectedQr: UUID = .zero {
        didSet {
            print("selectedQr", selectedQr)
            qrCodesService.setSelectedQR(id: selectedQr)
        }
    }

    func onAppear() {
        guard isProActivated,
              !storage.isFlipTipWasShown,
              let selected = qrCodesList.first(where: { $0.id == selectedQr }),
              selected.hasChangedColors else {
            return
        }
        showFlipTip = true
        storage.isFlipTipWasShown = true
    }

    func showDetails() {
        guard let currentQrModel = qrCodesService.getQR(id: selectedQr) else {
            return
        }
        generalAssembly.appRouter.route(route: .details(currentQrModel))
    }

    // MARK: - Private

    private func updateQrCodeList(_ qrCodes: [QRModel], isProActivated: Bool) {
        if qrCodes.count > 1, !isProActivated {
            let firstQrCode = qrCodes.first!
            self.qrCodesList = [firstQrCode]
            self.showNeedToPaySubscription = true
        } else {
            self.showNeedToPaySubscription = false
            self.qrCodesList = qrCodes
        }

        let selectedQRId = qrCodesService.selectedQRCodePublisher.value
        if qrCodesList.contains(where: { $0.id == selectedQRId }) {
            selectedQr = selectedQRId!
        } else {
            selectedQr = qrCodesList.first?.id ?? .zero
        }
    }
}

extension UUID {
    static let zero = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
}


