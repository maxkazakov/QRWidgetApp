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

        qrCodesService.selectedQRCodePublisher
            .removeDuplicates()
            .filter { $0 != nil }
            .map { $0! }
            .sink(receiveValue: { [weak self] selectedId in
                self?.selectedQr = selectedId
            })
            .store(in: &cancellableSet)
    }

    @Published var showFlipTip = false
    @Published var showNeedToPaySubscription = false
    @Published var qrCodesList: [QRModel] = []
    @Published var selectedQr: UUID = UUID() {
        didSet {
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

    private func updateQrCodeList(_ qrCodes: [QRModel], isProActivated: Bool) {
        if qrCodes.count > 1, !isProActivated {
            let firstQrCode = qrCodes.first!
            self.qrCodesList = [firstQrCode]
            self.showNeedToPaySubscription = true
        } else {
            self.showNeedToPaySubscription = false
            self.qrCodesList = qrCodes
        }
    }
}

private let unselectedId = UUID()


