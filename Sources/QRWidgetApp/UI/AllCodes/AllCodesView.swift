import SwiftUI
import CodeCreation
import SwiftUINavigation

struct AllCodesView: View {
    @StateObject var viewModel: AllCodesViewModel

    var body: some View {
        VStack {
            Picker("", selection: $viewModel.selectedTab) {
                Text(L10n.Allcodes.Segment.all).tag(SelectedTab.history)
                Text(L10n.Tabs.favorites).tag(SelectedTab.favorites)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            switch viewModel.selectedTab {
            case .favorites:
                FavoritesView(viewModel: viewModel.favoritesViewModel)
            case .history:
                HistoryView(viewModel: viewModel.historyViewModel)
            }
        }
        .navigationTitle(L10n.History.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.createdNewCodeTapped()
                } label: {
                    Text("Create new")
                }
            }
        }
        .sheet(
            unwrapping: $viewModel.destination,
            case: /AllCodesViewModel.Destination.newCode,
            onDismiss: {
                print("onDismiss", Int.random(in: 0..<1000))
                viewModel.destination = nil
            },
            content: { $viewModel in
                SelectingCodeTypeView(model: viewModel)
            })
    }
}
