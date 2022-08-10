//
//  IntentHandler.swift
//  QRWidgetIntent
//
//  Created by Максим Казаков on 10.08.2022.
//

import Intents
import os.log
import QRWidgetApp
import QRWidgetCore

class IntentHandler: INExtension, DynamicQRSelectionIntentHandling {
    func provideQrtypeOptionsCollection(for intent: DynamicQRSelectionIntent, with completion: @escaping (INObjectCollection<QRType>?, Error?) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now()) {
            let favoritesService = FavoritesService()
            let qrTypes: [QRType] = loadQRModels()
                .filter { favoritesService.isFavorite(qrId: $0.id) }
                .map { qrModel in
                    var title = ""
                    var subtitle: String?
                    if qrModel.label.isEmpty {
                        title = qrModel.qrData
                    } else {
                        title = qrModel.label
                        subtitle = qrModel.qrData
                    }
                    return QRType(identifier: qrModel.id.uuidString, display: title, subtitle: subtitle, image: nil)
                }
            let collection = INObjectCollection(items: qrTypes)
            completion(collection, nil)
        }
    }

    func defaultQrtype(for intent: DynamicQRSelectionIntent) -> QRType? {
        let favoritesService = FavoritesService()
        guard let firstQr = loadQRModels().filter({ favoritesService.isFavorite(qrId: $0.id) }).first else {
            return nil
        }
        let (title, subtitle) = qrTitleAndSubtitle(firstQr)
        return QRType(identifier: firstQr.id.uuidString, display: title, subtitle: subtitle, image: nil)
    }

    private func qrTitleAndSubtitle(_ qrModel: QRModel) -> (String, String?) {
        var title = ""
        var subtitle: String?
        if qrModel.label.isEmpty {
            title = qrModel.qrData
        } else {
            title = qrModel.label
            subtitle = qrModel.qrData
        }
        return (title, subtitle)
    }
}
