
import SwiftUI

struct MutlipleQRRecognizedView: View {
    let viewModel: MutlipleQRRecognizedViewModel
    @State var selectedQRId: UUID?

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.items, id: \.id) { item in
                    NavigationLink(
                        tag: item.id,
                        selection: $selectedQRId,
                        destination: {
                            viewModel.detailsView(id: item.id)
                        }, label: {
                            viewModel.rowView(item: item)
                                .padding(.vertical, 12)
                                .foregroundColor(Color.primary)
                        })
                }
            }
            .buttonStyle(PlainButtonStyle())
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Batch scan result")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
}

