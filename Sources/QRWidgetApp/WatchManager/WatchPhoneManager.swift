//
//  WatchManager.swift
//  QRWidget
//
//  Created by Максим Казаков on 02.07.2022.
//

import Foundation
import WatchConnectivity
import Combine
import UIKit
import QRWidgetCore
import CodeImageGenerator

final class WatchPhoneManager: NSObject {

    private let qrService: QRCodesService
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var cancellableSet = Set<AnyCancellable>()
    private var sessionStatePublisher = PassthroughSubject<WCSessionActivationState, Never>()

    private let transferDataQueue = DispatchQueue(label: "WatchPhoneManager")

    init(qrService: QRCodesService) {
        self.qrService = qrService
        super.init()
    }

    func startSession() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }

        qrService.favoriteQrCodes
            .combineLatest(sessionStatePublisher.removeDuplicates())
            .filter({ (_, sessionState) in
                sessionState == .activated
            })
            .receive(on: transferDataQueue)
            .sink(receiveValue: {
                self.onFavoritesChanged(qrModels: $0.0)
            })
            .store(in: &cancellableSet)
    }

    func onFavoritesChanged(qrModels: [CodeModel]) {
        Logger.debugLog(message: "WatchPhoneManager. On favorite changed called")
        let transferableModels: [CodeTransferData] = qrModels.enumerated().compactMap { orderIdx, model in
            guard let qrImage = CodeGenerator.shared.generateQRCode(from: model, size: .init(width: 300, height: 300), useCustomColorsIfPossible: false)
            else {
                return nil
            }
            guard let qrImageData = qrImage.pngData() else {
                return nil
            }
            Logger.debugLog(message: "WatchPhoneManager. Image size to send: \(ByteCountFormatter.string(fromByteCount: Int64(qrImageData.count), countStyle: .binary))")
            return CodeTransferData(id: model.id, imageData: qrImageData, label: model.label, orderIdx: orderIdx)
        }
        do {
            let data = try encoder.encode(transferableModels)
            try WCSession.default.updateApplicationContext([codesKey: data])
        } catch {
            Logger.debugLog(message: "WatchPhoneManager. Failed to update application context. Error: \(error)")
        }
    }
}

extension WatchPhoneManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Logger.debugLog(message: "WatchPhoneManager. WCSessionDelegate activationDidCompleteWith: \(activationState)")
        sessionStatePublisher.send(activationState)
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
    }

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}
