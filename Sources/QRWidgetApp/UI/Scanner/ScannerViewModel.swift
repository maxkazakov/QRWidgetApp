//
//  ScannerViewModel.swift
//  QRWidget
//
//  Created by Максим Казаков on 16.04.2022.
//

import SwiftUI
import Combine
import QRWidgetCore

class BatchScanResult {
    init(codes: [QRModel], batchId: UUID) {
        self.batchId = batchId
        self.codes = codes
    }
    let batchId: UUID
    var codes: [QRModel]
}

class ScannerViewModel: ViewModel {
    @Published var isScanActive = true
    @Published var batchScanResult: BatchScanResult?
    @Published var showBatchScanHint = false
    @Published var showPaywall = false

    var shouldVibrateOnSuccess: Bool {
        settingsService.vibrateOnCodeRecognized
    }

    var batchModeOn: Bool {
        batchScanResult != nil
    }

    private let qrCodeService: QRCodesService
    private let favoritesService: FavoritesService
    private let settingsService: SettingsService
    private let sendAnalytics: SendAnalyticsAction

    init(qrCodeService: QRCodesService,
         favoritesService: FavoritesService,
         settingsService: SettingsService,
         sendAnalytics: @escaping SendAnalyticsAction) {
        self.qrCodeService = qrCodeService
        self.favoritesService = favoritesService
        self.settingsService = settingsService
        self.sendAnalytics = sendAnalytics
        super.init()
    }

    func startBatchScan() {
        if self.isProActivated {
            if settingsService.batchUpdateHintWasShown {
                sendAnalytics(.startBatchScan, nil)
                batchScanResult = BatchScanResult(codes: [], batchId: UUID())
            } else {
                settingsService.batchUpdateHintWasShown = true
                showBatchScanHint = true
            }
        } else {
            showPaywall = true
        }
    }

    func finishBatchScan() {
        if batchScanResult!.codes.isEmpty {
            isScanActive = true
            batchScanResult = nil
            return
        }
        isScanActive = false
        route(.multipleCodesRecognized(codes: batchScanResult!.codes, completion: { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self?.isScanActive = true
            }
        }))
        batchScanResult = nil
    }

    func qrCodeFound(data: String, source: ScanResult.Source) {
        if batchModeOn {
            batchScanRecognized(data: data, source: source)
        } else {
            singleCodeRecognized(data: data, source: source)
        }
    }

    private func batchScanRecognized(data: String, source: ScanResult.Source) {
        sendAnalytics(.qrCodeRecogzined, ["source": mapScanSource(source).rawValue, "isBatchMode": true])
        isScanActive = false
        let newQr = qrCodeService.createNewQrCode(data: data, batchId: batchScanResult?.batchId)
        batchScanResult!.codes.append(newQr)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isScanActive = true
        }
    }

    private func singleCodeRecognized(data: String, source: ScanResult.Source) {
        sendAnalytics(.qrCodeRecogzined, ["source": mapScanSource(source).rawValue])
        isScanActive = false
        let newQr = qrCodeService.createNewQrCode(data: data)
        route(.details(newQr, options: CodeDetailsPresentaionOptions(isPopup: true, title: L10n.Scanner.Result.title, hideCodeImage: true), completion: { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self?.isScanActive = true
            }
        }))
    }

    func canAddToFavorites() -> Bool {
        guard !isProActivated else {
            return true
        }
        return favoritesService.favorites.value.count < 1
    }

    func failedToRecognize() {
        sendAnalytics(.qrFailedToRecognize, nil)
    }

    private func mapScanSource(_ source: ScanResult.Source) -> AnalyticsSource.QrRecognize {
        switch source {
        case .camera:
            return .camera
        case .gallery:
            return .gallery
        }
    }
}
