
import UIKit
import QRWidgetCore

struct CodeModelDto: Codable {
    init(
        id: UUID,
        dateCreated: Date,
        stringPayload: String?,
        descriptor: CIBarcodeDescriptor?,
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
        self.stringPayload = stringPayload
        self.descriptor = descriptor
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
    let stringPayload: String?
    let descriptor: CIBarcodeDescriptor?
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
        case stringPayload
        case descriptor
        case type
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(id, forKey: .id)
        try container.encode(dateCreated, forKey: .dateCreated)

        try container.encode(stringPayload, forKey: .stringPayload)
        if let descriptor {
            let descriptorData = try NSKeyedArchiver.archivedData(withRootObject: descriptor, requiringSecureCoding: false)
            try container.encode(descriptorData, forKey: .descriptor)
        }

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
        self.type = (try? container.decode(CodeType.self, forKey: .type)) ?? .qr

        if let qrData = try? container.decode(String.self, forKey: .qrData) {
            self.stringPayload = qrData
            self.descriptor = nil
        } else {
            self.stringPayload = try container.decode(String.self, forKey: .stringPayload)

            if let descriptorData = try? container.decodeIfPresent(Data.self, forKey: .descriptor) {
                let descriptorClass: CIBarcodeDescriptor.Type
                switch self.type {
                case .qr:
                    descriptorClass = CIQRCodeDescriptor.self
                case .aztec:
                    descriptorClass = CIAztecCodeDescriptor.self
                }
                self.descriptor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: descriptorClass, from: descriptorData)
            } else {
                self.descriptor = nil
            }
        }

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
