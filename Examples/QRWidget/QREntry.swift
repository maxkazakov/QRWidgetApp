//
//  QREntry.swift
//  QRWidgetAppExample
//
//  Created by Максим Казаков on 10.08.2022.
//

import WidgetKit
import SwiftUI
import QRWidgetCore
import QRWidgetApp

enum QRWidgetData {
    case placeholder
    case preview
    case real(QRModel?)

    var qrModel: QRModel? {
        switch self {
        case let .real(model):
            return model
        default:
            return nil
        }
    }
}

struct QREntry: TimelineEntry {
    let qrWidgetData: QRWidgetData

    var date: Date {
        Date.distantFuture
    }
}

func qrEntry(for configuration: DynamicQRSelectionIntent?) -> QREntry {
    let models = loadQRModels()
    let favoritesService = FavoritesService()
    let favoriteModels = models.filter { favoritesService.isFavorite(qrId: $0.id) }

    guard !models.isEmpty else {
        return .init(qrWidgetData: .real(nil))
    }

    let id = configuration?.qrtype?.identifier.map({ UUID(uuidString: $0) })
    let firstQr = favoriteModels.first
    // I don't receive intent qr from favorites, because in old versions used could select intent from full list of qrs, not only from favs
    let intentQr = models.first(where: { $0.id == id })

    let qrToShow = intentQr ?? firstQr

    return .init(qrWidgetData: .real(qrToShow))
}
