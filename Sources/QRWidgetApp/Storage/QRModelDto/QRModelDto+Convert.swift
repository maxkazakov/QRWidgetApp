//
//  CodeModelDto+Convert.swift
//  QRWidget
//
//  Created by Максим Казаков on 23.10.2021.
//

import Foundation
import QRWidgetCore

extension CodeModelDto {
    init(model: CodeModel) {
        self.id = model.id
        self.dateCreated = model.dateCreated

        self.stringPayload = model.data.stringPayload
        self.descriptor = model.data.descriptor

        self.type = model.type
        self.label = model.label
        self.errorCorrectionLevel = model.errorCorrectionLevel
        self.foregroundColor = model.foregroundColor
        self.backgroundColor = model.backgroundColor
        self.batchId = model.batchId
        self.isMy = model.isMy
        self.qrStyle = model.qrStyle
    }
    
    func makeModel() -> CodeModel {
        CodeModel(
            id: self.id,
            dateCreated: self.dateCreated,
            data: .init(stringPayload: self.stringPayload, descriptor: self.descriptor),
            type: self.type,
            label: self.label,
            errorCorrectionLevel: self.errorCorrectionLevel,
            backgroundColor: self.backgroundColor,
            foregroundColor: self.foregroundColor,
            batchId: self.batchId,
            isMy: self.isMy,
            qrStyle: self.qrStyle
        )
    }
}
