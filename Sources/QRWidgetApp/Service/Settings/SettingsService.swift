//
//  SettingsService.swift
//  QRWidget
//
//  Created by Максим Казаков on 25.06.2022.
//

import Foundation

class SettingsService {
    init(storage: UserDefaultsStorage) {
        self.storage = storage
    }

    let storage: UserDefaultsStorage

    var vibrateOnCodeRecognized: Bool {
        get { storage.vibrationOnCodeRecognized }
        set { storage.vibrationOnCodeRecognized = newValue }
    }

    var batchUpdateHintWasShown: Bool {
        get { storage.batchScanHintWasShown }
        set { storage.batchScanHintWasShown = newValue }
    }
}
