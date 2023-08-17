
import Foundation
import SwiftUI
import QRCodeUI
import SwiftUINavigation
import QRWidgetCore

public struct CodeCreationView: View {

    @EnvironmentObject var model: CodeCreationFlowModel
    @FocusState var focus: Field?

    public enum Field: Hashable {
        case first
    }

    public var body: some View {
        ZStack {
            Form {
                formSection

                Section {
                    HStack {
                        Spacer()
                        QRCodeTileView(data: .string(model.qrData), codeType: .qr)
                        Spacer()
                    }
                    .padding(.vertical, 16)
                }
            }
            .bind(self.$model.focus, to: self.$focus)
            .navigationTitle(L10n.codeContent)
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        model.onTapNext()
                    } label: {
                        Text(L10n.next)
                    }
                    .disabled(!model.canCreate)
                }
            }

            NavigationLink(
                unwrapping: $model.navigationDestination,
                case: /CodeCreationFlowModel.Destination.beautifying,
                onNavigate: { _ in

                },
                destination: { $beautifingViewModel in
                    BeautifyQRView(viewModel: beautifingViewModel)
                },
                label: {
                    EmptyView()
                }
            )
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
                    Text(CodeContentType.rawText.title)
                })
            }
            CaseLet(/QRFormData.url) { url in
                Section(content: {
                    TextEditor(text: url)
                        .focused($focus, equals: .first)
                }, header: {
                    Text(CodeContentType.url.title)
                })
            }
            CaseLet(/QRFormData.phone) { phone in
                Section(content: {
                    TextField("+49 172 761029", text: phone)
                        .keyboardType(.phonePad)
                        .focused($focus, equals: .first)
                }, header: {
                    Text(CodeContentType.phone.title)
                })
            }
            CaseLet(/QRFormData.email) { emailFormData in
                Section(content: {
                    TextField("example@mail.com", text: emailFormData.email)
                        .keyboardType(.emailAddress)
                        .focused($focus, equals: .first)
                }, header: {
                    Text(CodeContentType.email.title)
                })

                Section(content: {
                    TextEditor(text: emailFormData.subject)
                }, header: {
                    Text("Subject")
                }, footer: {
                    Text("This field is optional")
                })

                Section(content: {
                    TextEditor(text: emailFormData.message)
                }, header: {
                    Text("Message")
                }, footer: {
                    Text("This field is optional")
                })
            }
        })
    }
}

struct CreationCodeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CodeCreationView()
                .environmentObject(CodeCreationFlowModel(type: .phone))
                .navigationTitle("New code")
        }
    }
}
