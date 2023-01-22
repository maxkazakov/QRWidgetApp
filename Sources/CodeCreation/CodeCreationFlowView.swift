
import SwiftUI
import QRWidgetCore

public struct CodeCreationFlowView: View {

    @EnvironmentObject var model: CodeCreationFlowModel

    public init() {}

    public var body: some View {
        NavigationView {
            List {
                Section(content: {
                    ForEach(model.codeTypes) { type in
                        NavigationLink.init(
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
                    Text(L10n.selectQrType)
                })
            }
            .listStyle(.insetGrouped)
            .navigationTitle(L10n.codeType)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CodeCreationFlowView_Previews: PreviewProvider {
    static var previews: some View {
        CodeCreationFlowView()
            .environmentObject(CodeCreationFlowModel(type: .rawText))
    }
}
