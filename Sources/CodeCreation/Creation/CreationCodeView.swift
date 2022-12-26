
import SwiftUI
import QRWidgetCore
import QRCodeUI
import CasePaths
import SwiftUINavigation

enum QRFormData {
    case rawText(String)
    case url(String)

    var isValid: Bool {
        qrData() != nil
    }

    func qrData() -> QRCodeDataType? {
        switch self {
        case let .rawText(text):
            if text.isEmpty {
                return nil
            }
            return .rawText(text)
        case let .url(urlString):
            guard let url = URL(string: urlString), urlString.isValidURL else { return nil }
            return .url(url)
        }
    }
}

final public class CreationCodeModel: ObservableObject, Equatable, Identifiable {

    public var id: Int {
        self.type.rawValue
    }

    public static func == (lhs: CreationCodeModel, rhs: CreationCodeModel) -> Bool {
        lhs.type == rhs.type
    }

    @Published var qrDataType: QRFormData = .rawText("") {
        didSet {
            guard let qrdata = qrDataType.qrData() else {
                self.canCreate = false
                return
            }
            self.qrData = qrdata.qrString
            self.canCreate = true
        }
    }
    @Published var qrData: String = ""
    @Published var canCreate = false
    @Published var type: QRCodeType
    @Published var focus: CreationCodeView.Field?

    public init(type: QRCodeType, focus: CreationCodeView.Field? = .first) {
        self.focus = focus
        self.type = type
        switch type {
        case .url:
            qrDataType = .url("https://")
        case .rawText:
            qrDataType = .rawText("")
        }
    }
}

public struct CreationCodeView: View {
    @ObservedObject var model: CreationCodeModel
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
                    //do something
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
            CreationCodeView(model: .init(type: .rawText))
                .navigationTitle("New code")
        }
    }
}
