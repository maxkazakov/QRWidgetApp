//
//  Storage.swift
//  QRWidget
//
//  Created by Максим Казаков on 17.10.2021.
//

import Combine
import UIKit
import StoreKit

// LEGACY

class Storage {
    private let userDefaultsStorage = UserDefaultsStorage()
    private let decoder = JSONDecoder()
    static let filename = getDocumentsDirectory().appendingPathComponent("AppState.json")
    
    static func getDocumentsDirectory() -> URL {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)!
    }
    
    static func remove(url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
    
    private func canLoadFromFile() -> Bool {
        return FileManager.default.fileExists(atPath: Self.filename.path)
    }

    func loadStatePublisher() -> AnyPublisher<AppStateDto?, Never> {
        Deferred {
            Future<AppStateDto?, Never> { promise in
                DispatchQueue.global(qos: .userInitiated).async {
                    promise(.success(self.loadState()))
                }                
            }
        }
        .eraseToAnyPublisher()
    }

    private func loadState() -> AppStateDto? {
        if needMigrateFromUserDefailts(),
           let appStateDto = migrateFromUserDefaults() {
            return appStateDto
        }
        guard canLoadFromFile() else {
            return nil
        }
        do {
            let data = try Data(contentsOf: Self.filename)
            let state = try decoder.decode(AppStateDto.self, from: data)
            return state
        } catch {
            Logger.debugLog(message: "Failed to load from storage. Error: \(error) ")
            return nil
        }
    }
    
    private func needMigrateFromUserDefailts() -> Bool {
        userDefaultsStorage.qrLink != nil && userDefaultsStorage.migratedToFile != nil
    }
    
    private func migrateFromUserDefaults() -> AppStateDto? {
        guard let qrLink = userDefaultsStorage.qrLink else {
            return nil
        }
        let label = userDefaultsStorage.qrLabel ?? ""
        let serialNumber = userDefaultsStorage.serialNumber

        let qrModelDto = QRModelDto(
            id: UUID(),
            dateCreated: Date(),
            qrData: qrLink,
            label: label,
            errorCorrectionLevel: .H
        )
        let allWalletPasses = serialNumber.map { [qrModelDto.id: $0] } ?? [:]
        userDefaultsStorage.migratedToFile = "mirgated"
        let appState = AppStateDto(
            data: AppStateData_V2(
                selectedQR: nil,
                allQRs: [qrModelDto],
                allWalletPasses: allWalletPasses,
                isSubscriptionActivated: false,
                onboardingWasShown: false
            )
        )
        return appState
    }
}
