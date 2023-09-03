import SwiftUI
import SwiftUINavigation

struct AllCodesView: View {
    @StateObject var viewModel: AllCodesViewModel

    var body: some View {
        VStack {
            Picker("", selection: $viewModel.selectedTab) {
                Text(L10n.Allcodes.Segment.scans).tag(SelectedTab.scans)
                Text(L10n.Tabs.favorites).tag(SelectedTab.favorites)
                Text(L10n.Allcodes.Segment.my).tag(SelectedTab.my)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            switch viewModel.selectedTab {
            case .favorites:
                FavoritesView(viewModel: viewModel.favoritesViewModel)
            case .scans:
                HistoryView(viewModel: viewModel.historyViewModel)
            case .my:
                MyCodesListView(viewModel: viewModel.myCodesViewModel)
            }
        }
        .navigationTitle(L10n.History.title)
    }
}
