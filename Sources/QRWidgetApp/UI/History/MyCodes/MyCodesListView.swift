import SwiftUI
import UIKit

struct MyCodesListView: View {

    @ObservedObject var viewModel: MyCodesListViewModel
    @State var selectedQRId: UUID?
    @Environment(\.sendAnalyticsEvent) var sendAnalyticsEvent

    var body: some View {
        ZStack {
            if viewModel.codes.isEmpty {
                NoFavoriteCodesView()
            } else {
                List {
                    ForEach(viewModel.codes, id: \.id) { item in
                        rowView(item: item)
                    }
                    .onDelete { indexSet in
                        viewModel.remove(indexSet)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .listStyle(InsetGroupedListStyle())
            }
        }
    }

    @ViewBuilder
    func rowView(item: SingleCodeRowUIModel) -> some View {
        NavigationLink(
            tag: item.id,
            selection: $selectedQRId,
            destination: {
                viewModel.singleDetailsView(id: item.id)
            }, label: {
                viewModel.rowView(item: item)
                    .padding(.vertical, 12)
                    .foregroundColor(Color.primary)
            })
    }
}
