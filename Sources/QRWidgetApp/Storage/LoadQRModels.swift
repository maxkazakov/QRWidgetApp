//
//  File.swift
//  
//
//  Created by Максим Казаков on 09.08.2022.
//

import Foundation
import QRWidgetCore

// Loading QRs from state for showing on widget
public func loadQRModels() -> [QRModel] {
    let userDefaultsStorage = UserDefaultsStorage()

    // NEW
    let repo = QRCodesRepository(logMessage: { _ in })
    repo.loadAllQrFromStorage()
    let qrModels = repo.qrCodes

    if qrModels.count > 0 {
        return qrModels
    }
    if userDefaultsStorage.mirgatedFromRedux {
        return []
    }

    // Legacy
    let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)!
    let filename = directory.appendingPathComponent("AppState.json")
    guard FileManager.default.fileExists(atPath: filename.path) else {
        return getFromTheOldestStorage()
    }
    do {
        let data = try Data(contentsOf: filename)
        let state = try JSONDecoder().decode(AppStateDto.self, from: data)
        let qrModels = state.data.allQRs.map { $0.makeModel() }
        return qrModels
    } catch {
        print(error)
        return getFromTheOldestStorage()
    }
}

private func getFromTheOldestStorage() -> [QRModel] {
    let userDefaultsStorage = UserDefaultsStorage()
    guard let qrData = userDefaultsStorage.qrLink else {
        return []
    }
    let label = userDefaultsStorage.qrLabel ?? ""
    var qrModel = QRModel.zero
    qrModel.qrData = qrData
    qrModel.label = label
    return []
}
