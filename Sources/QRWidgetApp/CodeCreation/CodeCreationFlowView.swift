
import SwiftUI
import QRWidgetCore
import SimpleToast

public struct CodeCreationFlowView: View {

    @EnvironmentObject var model: CodeCreationFlowModel

    public init() {}

    public var body: some View {
        NavigationView {
            List {
                Section(content: {
                    ForEach(model.utilsCodeTypes) { type in
                        NavigationLink(
                            tag: type,
                            selection: $model.type,
                            destination: {
                                CodeCreationView()
                            },
                            label: {
                                Text(type.title)
                            }
                        )
                    }
                }, header: {
                    Text("Utils")
                })

                Section(content: {
                    ForEach(model.contactsCodeTypes) { type in
                        NavigationLink(
                            tag: type,
                            selection: $model.type,
                            destination: {
                                CodeCreationView()
                            },
                            label: {
                                Text(type.title)
                            }
                        )
                    }
                }, header: {
                    Text("Contacts")
                })
            }
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

struct CodeCreationFlowView_Previews: PreviewProvider {
    static var previews: some View {
        CodeCreationFlowView()
            .environmentObject(CodeCreationFlowModel())
    }
}
