
import SwiftUI
import QRWidgetCore
import QRCodeUI
import CasePaths
import SwiftUINavigation

final public class CreationCodeModel: ObservableObject {

    @Published var qrDataType: QRCodeDataType = .rawText("") {
        didSet {
            qrData = qrDataType.qrString
        }
    }
    @Published var qrData: String = ""

    public init(type: QRCodeType) {
        switch type {
        case .url:
            qrDataType = .rawText("")
        case .rawText:
            qrDataType = .url(URL(string: "https://")!)
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
            }
//
//            ToolbarItem(placement: .cancellationAction) {
//                Button {
//                    //do something
//                } label: {
//                    Text("Cancel")
//                }
//            }
        }
    }

    @ViewBuilder
    var formSection: some View {
        Switch($model.qrDataType, content: {
            CaseLet(/QRCodeDataType.rawText) { rawText in
                TextEditor(text: rawText)
            }
            CaseLet(/QRCodeDataType.url) { url in
                TextEditor(text: Binding(
                    get: { url.wrappedValue.absoluteString },
                    set: { url.wrappedValue = URL(string: $0) ?? URL(string: "https://")! }
                ))
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
