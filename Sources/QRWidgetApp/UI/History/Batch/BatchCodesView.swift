import SwiftUI
import UIKit

struct BatchCodesView: View {

    @StateObject var viewModel: BatchCodesViewModel
    @State var selectedQRId: UUID?
    @Environment(\.sendAnalyticsEvent) var sendAnalyticsEvent

    var body: some View {
        ZStack {
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
        .navigationTitle(viewModel.title)
        .onAppear(perform: { viewModel.onAppear() })
        .onChange(of: selectedQRId, perform: {
            if $0 != nil {
                sendAnalyticsEvent(.tapHistoryItem, nil)
            }
        })
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
