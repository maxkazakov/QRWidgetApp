
import SwiftUI
import QRWidgetCore
import QRCodeUI
import CasePaths
import SwiftUINavigation
import XCTestDynamicOverlay

final public class CodeCreationFlowModel: ObservableObject {

    public var onCodeCreatoinFinished: (QRModel) -> Void = unimplemented("SelectingCodeTypeModel.onCodeCreatoinFinished")
    @Published var codeTypes: [QRCodeType] = QRCodeType.allCases

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
    @Published var type: QRCodeType? {
        didSet {
            switch type {
            case .url:
                qrDataType = .url("https://")
            case .rawText:
                qrDataType = .rawText("")
            case .none:
                break
            }
        }
    }
    @Published var focus: CreationCodeView.Field? = .first

    public init(type: QRCodeType? = nil) {
        self.type = type
    }

    func onTapDone() {
        onCodeCreatoinFinished(QRModel(qrData: qrData, isMy: true))
    }
}
