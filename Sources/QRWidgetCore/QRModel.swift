
import Foundation
import UIKit

public struct QRModel: Identifiable, Equatable {
    public init(id: UUID = UUID(),
         dateCreated: Date = Date(),
         qrData: String,
         label: String = "",
         errorCorrectionLevel: ErrorCorrection = .default,
         backgroundColor: UIColor? = nil,
         foregroundColor: UIColor? = nil,
         batchId: UUID? = nil,
         isMy: Bool = false
    ) {
        self.id = id
        self.dateCreated = dateCreated
        self.qrData = qrData
        self.label = label
        self.errorCorrectionLevel = errorCorrectionLevel
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.batchId = batchId
        self.isMy = isMy
    }

    public var id: UUID
    public var dateCreated: Date
    public var qrData: String
    public var label: String = ""
    public var batchId: UUID?
    public var isMy: Bool

    public var errorCorrectionLevel: ErrorCorrection = .default
    public var backgroundColor: UIColor?
    public var foregroundColor: UIColor?
}

public extension QRModel {
    static let zero = QRModel(
        id: UUID(),
        dateCreated: Date(),
        qrData: "https://www.figma.com",
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
