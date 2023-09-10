
import SwiftUI
import SwiftUINavigation
import QRWidgetCore
import SimpleToast

struct CodeTypeSelectionView: View {

    @ObservedObject var model: CodeTypeSelectionViewModel

    var body: some View {
        NavigationView {
            List {
                Section(content: {
                    ForEach(model.utilsCodeTypes) { type in
                        Button(type.title, action: {
                            model.setNavigationLinkActive(type: type)
                        })
                    }
                }, header: {
                    Text("Utils")
                })

                Section(content: {
                    ForEach(model.contactsCodeTypes) { type in
                        Button(type.title, action: {
                            model.setNavigationLinkActive(type: type)
                        })
                    }
                }, header: {
                    Text("Contacts")
                })
            }
            .background(
                NavigationLink(
                    unwrapping: $model.navigationDestination,
                    case: /CodeTypeSelectionViewModel.Destination.codeContentForm
                ) { isActive in
                    if !isActive {
                        model.navigationDestination = nil
                    }
                } destination: { $model in
                    CodeContentFormView(model: model)
                } label: {
                    EmptyView()
                }
            )
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
        .navigationViewStyle(.stack)
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
