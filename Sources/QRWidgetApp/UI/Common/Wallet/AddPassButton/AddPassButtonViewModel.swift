//
//  AddPassButtonViewModel.swift
//  QRWidget
//
//  Created by Максим Казаков on 18.02.2022.
//

import SwiftUI
import PassKit
import QRWidgetCore

class AddToWalletButtonViewModel: ViewModel {

    init(walletService: WalletService, sendAnalyticsEvent: @escaping SendAnalyticsAction) {
        self.walletService = walletService
        self.sendAnalyticsEvent = sendAnalyticsEvent
        super.init()
    }

    @Published var status: Status = .notLoading
    @Published var presentGeneratedPass = false
    @Published var hasWalletPass = false
    @Published var presentErrorAlert = false

    let walletService: WalletService
    let sendAnalyticsEvent: SendAnalyticsAction
    var pass: PKPass?

    enum Status {
        case notLoading
        case loading
    }

    func checkHasPass(qrModel: QRModel) {
        self.hasWalletPass = walletService.allWalletPasses[qrModel.id] != nil
    }

    func generatePass(qrModel: QRModel) {
        sendAnalyticsEvent(.appleWalletClick, nil)
        status = .loading
        walletService.createPass(qrCode: qrModel)
            .sink(receiveCompletion: { [sendAnalyticsEvent] in
                if case let .failure(error) = $0 {
                    self.status = .notLoading
                    self.presentErrorAlert = true
                    sendAnalyticsEvent(.failedToCreateAppleWallet, ["error" : error.localizedDescription])
                }
            },
                  receiveValue: { [sendAnalyticsEvent] pass in
                self.pass = pass
                self.presentGeneratedPass = true
                sendAnalyticsEvent(.appleWalletCreated, nil)
            })
            .store(in: &cancellableSet)
    }

    func finish(qrModel: QRModel) {
        defer {
            presentGeneratedPass = false
            status = .notLoading
        }
        guard let pass = self.pass else {
            return
        }
        if walletService.checkPassCreated(pass, qrCode: qrModel) {
            walletService.addPass(qrId: qrModel.id, passId: pass.serialNumber)
            sendAnalyticsEvent(.failedToCreateAppleWallet, nil)
            hasWalletPass = true
        }
    }
}
