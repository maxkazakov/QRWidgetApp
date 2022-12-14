//
//  WalletService.swift
//  QRWidget
//
//  Created by Максим Казаков on 16.02.2022.
//

import PassKit
import Combine
import QRWidgetCore

public typealias PassSerialNumber = String

class WalletService {

    private let queue = DispatchQueue(label: "WalletQueue", qos: .background)
    private let walletPassEnvironment: WalletPassEnvironment
    private let passLibrary = PKPassLibrary()
    private let userDefaults: UserDefaultsStorage
    private let analyticsEnvironment: AnalyticsEnvironment

    init(userDefaults: UserDefaultsStorage, walletPassEnvironment: WalletPassEnvironment, analyticsEnvironment: AnalyticsEnvironment) {
        self.walletPassEnvironment = walletPassEnvironment
        self.userDefaults = userDefaults
        self.analyticsEnvironment = analyticsEnvironment
    }

    private(set) var allWalletPasses: [UUID: PassSerialNumber] = [:] {
        didSet {
            analyticsEnvironment.updateWalletPassCount(passCount: allWalletPasses.count)
            userDefaults.walletPassesByQRCodeId = allWalletPasses
        }
    }

    func createPass(qrCode: QRModel) -> AnyPublisher<PKPass, Error> {
        let serialNumber = allWalletPasses[qrCode.id] ?? UUID().uuidString
        return walletPassEnvironment.createPass(WalletPassInputParams(serialNumber: serialNumber, data: qrCode.qrData, label: qrCode.label))
    }

    func loadAndValidatePasses() {
        let allWalletPassesFromStorage = userDefaults.walletPassesByQRCodeId
        let validatedPasses = allWalletPassesFromStorage.filter { _, serialNumber in
            passLibrary.pass(withPassTypeIdentifier: walletPassEnvironment.passIdentifier(), serialNumber: serialNumber) != nil
        }
        self.allWalletPasses = validatedPasses
    }

    func checkPassCreated(_ pass: PKPass, qrCode: QRModel) -> Bool {
        return passLibrary.containsPass(pass)
    }

    func addPass(qrId: UUID, passId: String) {
        allWalletPasses[qrId] = passId
    }

    func deletePass(by id: UUID) {
        guard let serialNumber = allWalletPasses[id] else {
            return
        }
        let passLibrary = PKPassLibrary()
        if let pass = passLibrary.pass(withPassTypeIdentifier: walletPassEnvironment.passIdentifier(), serialNumber: serialNumber) {
            passLibrary.removePass(pass)
        }
        self.allWalletPasses.removeValue(forKey: id)
    }
}
