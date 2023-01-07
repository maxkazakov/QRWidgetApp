
import Foundation

public struct CodeTransferData: Identifiable, Codable {

    public init(id: UUID, imageData: Data, label: String, orderIdx: Int) {
        self.id = id
        self.imageData = imageData
        self.label = label
        self.orderIdx = orderIdx
    }

    public let id: UUID
    public let imageData: Data
    public let label: String
    public let orderIdx: Int
}

public let codesKey = "codes"
