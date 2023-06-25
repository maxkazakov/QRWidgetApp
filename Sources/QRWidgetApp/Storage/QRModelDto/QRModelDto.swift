
import UIKit
import QRWidgetCore

struct CodeModelDto: Codable {
    init(
        id: UUID,
        dateCreated: Date,
        data: String,
        type: CodeType,
        label: String,
        errorCorrectionLevel: ErrorCorrection,
        backgroundColor: UIColor? = nil,
        foregroundColor: UIColor? = nil,
        batchId: UUID? = nil,
        isMy: Bool
    ) {
        self.id = id
        self.dateCreated = dateCreated
        self.data = data
        self.type = type
        self.label = label
        self.errorCorrectionLevel = errorCorrectionLevel
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.isMy = isMy
    }

    let version = currentVersion
    let id: UUID
    let dateCreated: Date
    let data: String
    let type: CodeType
    let label: String

    var errorCorrectionLevel: ErrorCorrection
    var backgroundColor: UIColor?
    var foregroundColor: UIColor?

    var batchId: UUID?
    var isMy: Bool
    
    enum CodingKeys: CodingKey {
        case version
        case id
        case dateCreated
        case qrData // deprecated
        case label
        case errorCorrectionLevel
        case backgroundColor
        case foregroundColor
        case batchId
        case isMy
        case data
        case type
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(id, forKey: .id)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(data, forKey: .data)
        try container.encode(type, forKey: .type)
        try container.encode(label, forKey: .label)
        try container.encode(batchId, forKey: .batchId)
        try container.encode(isMy, forKey: .isMy)

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

        if let qrData = try? container.decode(String.self, forKey: .qrData) {
            self.data = qrData
        } else {
            self.data = try container.decode(String.self, forKey: .data)
        }

        self.type = (try? container.decode(CodeType.self, forKey: .type)) ?? .qr

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
        self.isMy = try container.decodeIfPresent(Bool.self, forKey: .isMy) ?? false
    }
}

extension CodeModelDto {
    static let currentVersion = 3
}

