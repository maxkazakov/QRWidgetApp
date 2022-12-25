import SwiftUI
import CodeCreation

enum SelectedTab: Int {
    case favorites = 0
    case history = 1
}

class AllCodesViewModel: ObservableObject {

    enum Destination {
        case newCode(SelectingCodeTypeModel)
    }

    init(historyViewModel: HistoryViewModel, favoritesViewModel: FavoritesViewModel) {
        self.historyViewModel = historyViewModel
        self.favoritesViewModel = favoritesViewModel
    }

    @Published var selectedTab: SelectedTab = .history
    @Published var destination: Destination?

    let historyViewModel: HistoryViewModel
    let favoritesViewModel: FavoritesViewModel

    func createdNewCodeTapped() {
        destination = .newCode(SelectingCodeTypeModel())
    }
}
