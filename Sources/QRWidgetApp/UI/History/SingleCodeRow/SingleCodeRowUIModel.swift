
import Foundation
import QRWidgetCore

struct SingleCodeRowUIModel {
    let id: UUID
    let label: String
    let codeType: CodeType
    let qrData: CodeContent
    var isFavorite: Bool
    let date: Date
    let isMy: Bool
}

extension SingleCodeRowUIModel {
    init(model: CodeModel, isFavorite: Bool) {
        self.init(
            id: model.id,
            label: model.label,
            codeType: model.type,
            qrData: CodeContent.make(from: model.data.stringPayload),
            isFavorite: isFavorite,
            date: model.dateCreated,
            isMy: model.isMy
        )
    }
}
