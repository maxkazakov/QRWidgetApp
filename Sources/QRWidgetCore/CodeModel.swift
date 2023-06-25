
import Foundation
import UIKit

public struct CodeModel: Identifiable, Equatable {
    public init(
        id: UUID = UUID(),
        dateCreated: Date = Date(),
        data: String,
        type: CodeType,
        label: String = "",
        errorCorrectionLevel: ErrorCorrection = .default,
        backgroundColor: UIColor? = nil,
        foregroundColor: UIColor? = nil,
        batchId: UUID? = nil,
        isMy: Bool = false
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
    }

    public var id: UUID
    public var dateCreated: Date
    public var data: String
    public let type: CodeType
    public var label: String = ""
    public var batchId: UUID?
    public var isMy: Bool

    public var errorCorrectionLevel: ErrorCorrection = .default
    public var backgroundColor: UIColor?
    public var foregroundColor: UIColor?
}

public extension CodeModel {
    static let zero = CodeModel(
        id: UUID(),
        dateCreated: Date(),
        data: "https://www.figma.com",
        type: .qr,
        label: "Ticket",
        errorCorrectionLevel: ErrorCorrection.default,
        backgroundColor: nil,
        foregroundColor: nil
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
