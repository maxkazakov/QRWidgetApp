
import Foundation
import SwiftUI
import QRCodeUI
import SwiftUINavigation
import QRWidgetCore
import MapKit
import CoreLocationUI

public struct CodeContentFormView: View {

    @ObservedObject var model: CodeContentFormViewModel
    @FocusState var focus: Field?

    public enum Field: Hashable {
        case first
    }

    public var body: some View {
        ZStack {
            formSection
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
                case: /CodeContentFormViewModel.Destination.beautifying,
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
        Switch($model.qrFormData, content: {
            CaseLet(/QRFormData.rawText) { rawText in
                Form {
                    Section(content: {
                        TextEditor(text: rawText)
                            .focused($focus, equals: .first)
                    }, header: {
                        Text(CodeContentType.rawText.title)
                    })
                }
            }
            CaseLet(/QRFormData.url) { url in
                Form {
                    Section(content: {
                        TextEditor(text: url)
                            .focused($focus, equals: .first)
                    }, header: {
                        Text(CodeContentType.url.title)
                    })
                }
            }
            CaseLet(/QRFormData.phone) { phone in
                Form {
                    Section(content: {
                        TextField("+49 172 761029", text: phone)
                            .keyboardType(.phonePad)
                            .focused($focus, equals: .first)
                    }, header: {
                        Text(CodeContentType.phone.title)
                    })
                }
            }
            CaseLet(/QRFormData.location) { locationData in
                MapFormView(
                    viewModel: MapFormViewModel(
                        locationData: locationData
                    )
                )
            }
            CaseLet(/QRFormData.email) { emailFormData in
                Form {
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
            }
            CaseLet(/QRFormData.wifi) { wifiData in
                Form {
                    Section(content: {
                        TextEditor(text: wifiData.ssid)
                            .focused($focus, equals: .first)
                    }, header: {
                        Text("Network name (SSID)")
                    })

                    Section(content: {
                        TextEditor(text: wifiData.password)
                    }, header: {
                        Text("Password")
                    })

                    Section(content: {
                        Picker("Encryption type", selection: wifiData.encryption) {
                            ForEach(WifiFormData.Encryption.allCases) { encryption in
                                Text(encryption.description).tag(encryption)
                            }
                        }
                    }, header: {
                        Text("Encryption")
                    })
                }
            }
        })
    }
}

struct CodeContentFormView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CodeContentFormView(model: CodeContentFormViewModel(type: .email))
                .navigationTitle("New code")
        }
    }
}
