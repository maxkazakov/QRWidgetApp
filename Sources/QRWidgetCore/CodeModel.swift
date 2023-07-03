#if os(watchOS)
#else
import UIKit
import CoreImage

public struct CodeModel: Identifiable, Equatable {

    public enum DataType: Equatable {
        case string(String)
        case descriptor(CIBarcodeDescriptor)
        case combined(String, CIBarcodeDescriptor)

        public var stringPayload: String? {
            switch self {
            case let .string(stringPayload), let .combined(stringPayload, _):
                return stringPayload
            default:
                return nil
            }
        }

        public var descriptor: CIBarcodeDescriptor? {
            switch self {
            case let .descriptor(descriptor), let .combined(_, descriptor):
                return descriptor
            default:
                return nil
            }
        }

        public init(stringPayload: String?, descriptor: CIBarcodeDescriptor?) {
            switch (stringPayload, descriptor) {
            case let (.some(stringPayloadUnwrapped), .some(descriptorUnwrapped)):
                self = .combined(stringPayloadUnwrapped, descriptorUnwrapped)
            case let (.some(stringPayloadUnwrapped), .none):
                self = .string(stringPayloadUnwrapped)
            case let (.none, .some(descriptorUnwrapped)):
                self = .descriptor(descriptorUnwrapped)
            default:
                fatalError("At least one parameter should not be null")
            }
        }
    }

    public init(
        id: UUID = UUID(),
        dateCreated: Date = Date(),
        data: DataType,
        type: CodeType,
        label: String = "",
        errorCorrectionLevel: ErrorCorrection = .default,
        backgroundColor: UIColor? = nil,
        foregroundColor: UIColor? = nil,
        batchId: UUID? = nil,
        isMy: Bool = false,
        qrStyle: QRStyle? = nil
    ) {
        self.id = id
        self.dateCreated = dateCreated
        self.data = data
        self.type = type
        self.label = label
        self.errorCorrectionLevel = errorCorrectionLevel
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.batchId = batchId
        self.isMy = isMy
        self.qrStyle = qrStyle
    }

    public var id: UUID
    public var dateCreated: Date
    public var data: DataType
    public let type: CodeType
    public var label: String = ""
    public var batchId: UUID?
    public var isMy: Bool

    public var errorCorrectionLevel: ErrorCorrection = .default
    public var backgroundColor: UIColor?
    public var foregroundColor: UIColor?
    public var qrStyle: QRStyle?

    // Used for Aztec codes only
    public func descriptorRawBytes() -> Data? {
        let descriptor = data.descriptor
        switch type {
        case .aztec:
            guard let aztecDescriptor = descriptor as? CIAztecCodeDescriptor else {
                return nil
            }
            return aztecDescriptor.errorCorrectedPayload
        default:
            return nil
        }
    }
}

public extension CodeModel {
    static let zero = CodeModel(
        id: UUID(),
        dateCreated: Date(),
        data: .string("https://www.figma.com"),
        type: .qr,
        label: "Ticket",
        errorCorrectionLevel: ErrorCorrection.default,
        backgroundColor: nil,
        foregroundColor: nil,
        qrStyle: nil
    )
}

public enum ErrorCorrection: String, Codable, CaseIterable, Hashable {
    case L
    case M
    case Q
    case H

    public var title: String {
        switch self {
        case .L:
            return "7%"
        case .M:
            return "15%"
        case .Q:
            return "25%"
        case .H:
            return "30%"
        }
    }

    public static let `default` = ErrorCorrection.Q
}
#endif

