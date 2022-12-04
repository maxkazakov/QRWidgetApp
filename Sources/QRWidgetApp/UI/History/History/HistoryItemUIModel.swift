
import Foundation

struct HistoryItemUIModel: Identifiable {
    var id: UUID {
        switch data {
        case let .single(data):
            return data.id
        case let .multiple(data):
            return data.batchId
        }
    }

    var date: Date {
        switch data {
        case let .single(data):
            return data.date
        case let .multiple(data):
            return data.date
        }
    }

    let data: HistoryItemType
}

enum HistoryItemType {
    case single(SingleCodeRowUIModel)
    case multiple(HistoryMultipleCodesUIModel)
}

struct HistoryMultipleCodesUIModel {
    var date: Date {
        codes.first?.date ?? Date()
    }
    let batchId: UUID
    var codes: [SingleCodeRowUIModel]
}

struct HistorySectionUIModel: Identifiable {
    var id: Int { day }
    let day: Int
    let formattedDate: String
    var items: [HistoryItemUIModel]
}
