
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

    public init(type: QRCodeType) {
        self.type = type
        switch type {
        case .url:
            qrDataType = .url("https://")
        case .rawText:
            qrDataType = .rawText("")
        }
    }
}

struct CreationCodeView: View {
    @ObservedObject var model: CreationCodeModel

    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    QRCodeTileView(qrData: model.qrData)
                    Spacer()
                }
                .padding(.vertical, 16)
            }
            Section(content: {
                formSection
            }, header: {
                Text("Form")
            })
        }
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
                TextEditor(text: rawText)
            }
            CaseLet(/QRFormData.url) { url in
                TextEditor(text: url)
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
