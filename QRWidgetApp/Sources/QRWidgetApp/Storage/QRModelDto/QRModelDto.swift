//
//  QRModelDto.swift
//  QRWidget
//
//  Created by Максим Казаков on 17.10.2021.
//

import UIKit
import QRWidgetCore

struct QRModelDto: Codable {
    init(id: UUID, dateCreated: Date, qrData: String, label: String, errorCorrectionLevel: ErrorCorrection, backgroundColor: UIColor? = nil, foregroundColor: UIColor? = nil, batchId: UUID? = nil) {
        self.id = id
        self.dateCreated = dateCreated
        self.qrData = qrData
        self.label = label
        self.errorCorrectionLevel = errorCorrectionLevel
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor

    }

    let version = currentVersion
    let id: UUID
    let dateCreated: Date
    let qrData: String
    let label: String

    var errorCorrectionLevel: ErrorCorrection
    var backgroundColor: UIColor?
    var foregroundColor: UIColor?

    var batchId: UUID?
    
    enum CodingKeys: CodingKey {
        case version
        case id
        case dateCreated
        case qrData
        case label
        case errorCorrectionLevel
        case backgroundColor
        case foregroundColor
        case batchId
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(id, forKey: .id)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(qrData, forKey: .qrData)
        try container.encode(label, forKey: .label)
        try container.encode(batchId, forKey: .batchId)

        try container.encode(errorCorrectionLevel, forKey: .errorCorrectionLevel)

        if let backgorundColor = backgroundColor {
            let backgorundColorData = try NSKeyedArchiver.archivedData(withRootObject: backgorundColor, requiringSecureCoding: false)
            try container.encode(backgorundColorData, forKey: .backgroundColor)
        }
        if let foregroundColor = foregroundColor {
            let foregroundColorData = try NSKeyedArchiver.archivedData(withRootObject: foregroundColor, requiringSecureCoding: false)
            try container.encode(foregroundColorData, forKey: .foregroundColor)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let version = try container.decode(Int.self, forKey: .version)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.qrData = try container.decode(String.self, forKey: .qrData)
        self.label = try container.decode(String.self, forKey: .label)

        self.errorCorrectionLevel = try container.decodeIfPresent(ErrorCorrection.self, forKey: .errorCorrectionLevel)
            ?? .default

        if let backgorundColorData = try? container.decodeIfPresent(Data.self, forKey: .backgroundColor),
           let backgorundColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: backgorundColorData) {
            self.backgroundColor = backgorundColor
        }

        if let foregroundColorData = try? container.decodeIfPresent(Data.self, forKey: .foregroundColor),
           let foregroundColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: foregroundColorData) {
            self.foregroundColor = foregroundColor
        }

        self.batchId = try container.decodeIfPresent(UUID.self, forKey: .batchId)
    }
}

extension QRModelDto {
    static let currentVersion = 2
}

