
import SwiftUI
import UIKit
import SwiftUINavigation

struct HistoryView: View {

    @ObservedObject var viewModel: HistoryViewModel
    @State var selectedQRId: UUID?
    @Environment(\.sendAnalyticsEvent) var sendAnalyticsEvent
    @State private var confirmationShown = false
    
    var body: some View {
        ZStack {
            if viewModel.sections.isEmpty {
                NoHistoryView(startScanningTapped: viewModel.startScanningTapped)
            } else {
                List {
                    ForEach(viewModel.sections) { section in
                        Section(
                            content: {
                                ForEach(section.items, id: \.id) { item in
                                    rowView(item: item)
                                }
                                .onDelete { indexSet in
                                    viewModel.userTappedRemove(indexSet: indexSet, section: section)
                                }
                            },
                            header: {
                                Text(section.formattedDate)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        )
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .listStyle(InsetGroupedListStyle())
            }
        }
        .alert(
            unwrapping: self.$viewModel.destination,
            case: /HistoryViewModel.Destination.alert
        ) { action in
            switch action {
            case let .confirmRemoval(indices, section):
                viewModel.remove(indices, section: section)
            }
        }
        .onAppear(perform: { viewModel.onAppear() })
        .onChange(of: selectedQRId, perform: {
            if $0 != nil {
                sendAnalyticsEvent(.tapHistoryItem, nil)
            }
        })
    }

    @ViewBuilder
    func rowView(item: HistoryItemUIModel) -> some View {
        NavigationLink(
            tag: item.id,
            selection: $selectedQRId,
            destination: {
                switch item.data {
                case .single:
                    viewModel.singleDetailsView(id: item.id)
                case .multiple:
                    viewModel.mutlipleDetailsView(batchId: item.id)
                }
            }, label: {
                switch item.data {
                case let .single(single):
                    viewModel.rowView(item: single)
                        .padding(.vertical, 12)
                        .foregroundColor(Color.primary)
                case let .multiple(multiple):
                    HistoryMultipleRowView(model: multiple)
                        .padding(.vertical, 12)
                        .foregroundColor(Color.primary)
                }
            })
    }
}
