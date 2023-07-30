
import SwiftUI
import Combine
import QRWidgetCore
import AVFoundation

class BatchScanResult {
    init(codes: [CodeModel], batchId: UUID) {
        self.batchId = batchId
        self.codes = codes
    }
    let batchId: UUID
    var codes: [CodeModel]
}

class ScannerViewModel: ViewModel {
    @Published var isScanActive = true
    @Published var batchScanResult: BatchScanResult?
    @Published var showBatchScanHint = false
    @Published var showPaywall = false

    var availableCodeTypesForScanning: [AVMetadataObject.ObjectType] = [
        .qr,
        .aztec,
        .ean13,
        .ean8,
        .code128,
        .code39
    ]

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

    func codeFound(_ scanResult: ScanResult) {
        print("Core recognized! \(scanResult.descriptor), type: \(type(of: scanResult.descriptor)), data: \(scanResult.string ?? "")")
        guard let codeType = CodeType(avType: scanResult.type) else {
            return
        }
        if batchModeOn {
            batchScanRecognized(result: scanResult, codeType: codeType)
        } else {
            singleCodeRecognized(result: scanResult, codeType: codeType)
        }
    }

    private func batchScanRecognized(result: ScanResult, codeType: CodeType) {
        sendAnalytics(.qrCodeRecogzined, ["source": mapScanSource(result.source).rawValue, "isBatchMode": true])
        isScanActive = false
        let newQr = qrCodeService.createNewQrCode(
            stringPayload: result.string,
            descriptor: result.descriptor,
            type: codeType,
            batchId: batchScanResult?.batchId
        )
        batchScanResult!.codes.append(newQr)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isScanActive = true
        }
    }

    private func singleCodeRecognized(result: ScanResult, codeType: CodeType) {
        sendAnalytics(.qrCodeRecogzined, ["source": mapScanSource(result.source).rawValue])
        isScanActive = false
        let newQr = qrCodeService.createNewQrCode(
            stringPayload: result.string,
            descriptor: result.descriptor,
            type: codeType
        )
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

extension CodeType {
    init?(avType: AVMetadataObject.ObjectType) {
        switch avType {
        case .qr:
            self = .qr
        case .aztec:
            self = .aztec
        case .ean13:
            self = .ean13
        case .ean8:
            self = .ean8
        case .code128:
            self = .code128
        case .code39:
            self = .code39        
        default:
            return nil
        }
    }
}
