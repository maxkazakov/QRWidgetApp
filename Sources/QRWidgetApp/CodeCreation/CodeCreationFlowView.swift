
import SwiftUI
import QRWidgetCore

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
        }
        .navigationViewStyle(.stack)
    }
}

struct CodeCreationFlowView_Previews: PreviewProvider {
    static var previews: some View {
        CodeCreationFlowView()
            .environmentObject(CodeCreationFlowModel(type: nil))
    }
}
