
import SwiftUI
import SwiftUINavigation
import QRWidgetCore
import SimpleToast

struct CodeTypeSelectionRowView: View {
    @ObservedObject var model: CodeTypeRowModel

    var body: some View {
        NavigationLink(
            unwrapping: $model.navigationDestination,
            case: /CodeTypeRowModel.Destination.codeContentForm
        ) { isActive in
            if !isActive {
                model.navigationDestination = nil
            } else {
                model.setNavigationLinkActive()
            }
        } destination: { $model in
            CodeContentFormView(model: model)
        } label: {
            Label(model.type.title, systemImage: model.systemImage)            
        }
    }
}

struct CodeTypeSelectionView: View {

    @ObservedObject var model: CodeTypeSelectionViewModel

    @ViewBuilder
    var contentView: some View {
        List {
            Section(content: {
                ForEach(model.generalCodeTypes) { rowModel in
                    CodeTypeSelectionRowView(model: rowModel)
                }
            }, header: {
                Text("General")
            })

            Section(content: {
                ForEach(model.contactsCodeTypes) { rowModel in
                    CodeTypeSelectionRowView(model: rowModel)
                }
            }, header: {
                Text("Contacts")
            })

            Section(content: {
                ForEach(model.utilsCodeTypes) { rowModel in
                    CodeTypeSelectionRowView(model: rowModel)
                }
            }, header: {
                Text("Utils")
            })
        }
    }

    @ViewBuilder
    func navigationViewWrapper(@ViewBuilder contentView: () -> some View) -> some View {
        // Pop back doen't work with NavigationStack
//        if #available(iOS 16.0, *) {
//            NavigationStack {
//                contentView()
//            }
//        } else {
            NavigationView {
                contentView()
            }
            .navigationViewStyle(.stack)
//        }
    }

    var body: some View {
        navigationViewWrapper {
            contentView
                .listStyle(.insetGrouped)
                .navigationTitle(L10n.codeType)
                .navigationBarTitleDisplayMode(.inline)
                .simpleToast(
                    isPresented: $model.showToast,
                    options: SimpleToastOptions(
                        alignment: .bottom,
                        hideAfter: 5,
                        modifierType: .slide,
                        dismissOnTap: false
                    )
                ) {
                    toastView
                }
        }
    }

    @ViewBuilder
    var toastView: some View {
        VStack {
            Button("QR-code created. Tap to open My codes", action: {
                model.goToMyCodes()
            })
        }
        .padding()
        .background(
            Capsule()
                .foregroundColor(Color.blue)
        )
        .foregroundColor(Color.white)
        .cornerRadius(10)
        .padding(.bottom, 8)
    }
}

struct CodeTypeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CodeTypeSelectionView(model: CodeTypeSelectionViewModel())
    }
}
