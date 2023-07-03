
import SwiftUI
import QRWidgetCore
import QRCodeUI
import CasePaths
import SwiftUINavigation
import XCTestDynamicOverlay

final public class CodeCreationFlowModel: ObservableObject {

    public var onCodeCreatoinFinished: (CodeModel) -> Void = unimplemented("SelectingCodeTypeModel.onCodeCreatoinFinished")
    @Published var codeTypes: [CodeContentType] = [CodeContentType.rawText, CodeContentType.binary]

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
    @Published var type: CodeContentType? {
        didSet {
            focus = .first
            switch type {
            case .url:
                qrDataType = .url("https://")
            case .rawText:
                qrDataType = .rawText("")
            default:
                break
            }
        }
    }
    @Published var focus: CodeCreationView.Field? = .first

    public init(type: CodeContentType? = nil) {
        self.type = type
    }

    func onTapDone() {
        onCodeCreatoinFinished(CodeModel(data: .string(qrData), type: .qr, isMy: true, qrStyle: nil))
    }
}
