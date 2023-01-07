
import Foundation
import SwiftUI
import QRCodeUI
import SwiftUINavigation

public struct CodeCreationView: View {
    @EnvironmentObject var model: CodeCreationFlowModel
    @FocusState var focus: Field?

    public enum Field: Hashable {
        case first
    }

    public var body: some View {
        Form {
            formSection

            Section {
                HStack {
                    Spacer()
                    QRCodeTileView(qrData: model.qrData)
                    Spacer()
                }
                .padding(.vertical, 16)
            }
        }
        .bind(self.$model.focus, to: self.$focus)
        .navigationTitle("Code content")
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    model.onTapDone()
                } label: {
                    Text("Done")
                }
                .disabled(!model.canCreate)
            }
        }
    }

    @ViewBuilder
    var formSection: some View {
        Switch($model.qrDataType, content: {
            CaseLet(/QRFormData.rawText) { rawText in
                Section(content: {
                    TextEditor(text: rawText)
                        .focused($focus, equals: .first)
                    //                        .toolbar {
                    //                            ToolbarItemGroup(placement: .keyboard) {
                    //                                Spacer()
                    //                                Button("Done") {
                    //                                    model.focus = nil
                    //                                }
                    //                            }
                    //                        }
                }, header: {
                    Text("Text")
                })
            }
            CaseLet(/QRFormData.url) { url in
                Section(content: {
                    TextEditor(text: url)
                        .focused($focus, equals: .first)
                }, header: {
                    Text("Website")
                })
            }
        })
    }
}

struct CreationCodeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CodeCreationView()
                .environmentObject(CodeCreationFlowModel())
                .navigationTitle("New code")
        }
    }
}
