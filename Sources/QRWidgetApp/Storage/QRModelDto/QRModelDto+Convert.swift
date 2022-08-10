//
//  QRModelDto+Convert.swift
//  QRWidget
//
//  Created by Максим Казаков on 23.10.2021.
//

import Foundation
import QRWidgetCore

extension QRModelDto {
    init(model: QRModel) {
        self.id = model.id
        self.dateCreated = model.dateCreated
        self.qrData = model.qrData
        self.label = model.label
        self.errorCorrectionLevel = model.errorCorrectionLevel
        self.foregroundColor = model.foregroundColor
        self.backgroundColor = model.backgroundColor
        self.batchId = model.batchId
    }
    
    func makeModel() -> QRModel {
        QRModel(
            id: self.id,
            dateCreated: self.dateCreated,
            qrData: self.qrData,
            label: self.label,
            errorCorrectionLevel: self.errorCorrectionLevel,
            backgroundColor: self.backgroundColor,
            foregroundColor: self.foregroundColor,
            batchId: self.batchId
        )
    }
}
