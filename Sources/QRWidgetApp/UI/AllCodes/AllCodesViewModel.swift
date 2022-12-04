import SwiftUI

enum SelectedTab: Int {
    case favorites = 0
    case history = 1
}

class AllCodesViewModel: ObservableObject {
    
    init(selectedTab: SelectedTab = .favorites, historyViewModel: HistoryViewModel, favoritesViewModel: HistoryViewModel) {
        self.selectedTab = selectedTab
        self.historyViewModel = historyViewModel
        self.favoritesViewModel = favoritesViewModel
    }

    @Published var selectedTab: SelectedTab = .favorites

    let historyViewModel: HistoryViewModel
    let favoritesViewModel: HistoryViewModel
}
