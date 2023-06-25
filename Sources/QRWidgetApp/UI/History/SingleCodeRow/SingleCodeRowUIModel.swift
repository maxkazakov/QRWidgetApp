//
//  SingleCodeRowUIModel.swift
//  QRWidget
//
//  Created by Максим Казаков on 15.06.2022.
//

import Foundation
import QRWidgetCore

struct SingleCodeRowUIModel {
    let id: UUID
    let label: String
    let qrData: QRCodeDataType
    var isFavorite: Bool
    let date: Date
    let isMy: Bool
}

extension SingleCodeRowUIModel {
    init(model: CodeModel, isFavorite: Bool) {
        self.init(
            id: model.id,
            label: model.label,
            qrData: QRCodeDataType.make(from: model.data),
            isFavorite: isFavorite,
            date: model.dateCreated,
            isMy: model.isMy
        )
    }
}
