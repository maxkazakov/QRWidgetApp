import SwiftUI

struct AllCodesView: View {
    @StateObject var viewModel: AllCodesViewModel

    var body: some View {
        VStack {
            Picker("", selection: $viewModel.selectedTab) {
                Text("All").tag(SelectedTab.history)
                Text("Favorites").tag(SelectedTab.favorites)
            }
            .pickerStyle(.segmented)

            switch viewModel.selectedTab {
            case .favorites:
                FavoritesView(viewModel: viewModel.favoritesViewModel)
            case .history:
                HistoryView(viewModel: viewModel.historyViewModel)
            }
        }
        .navigationTitle(L10n.History.title)
    }
}
