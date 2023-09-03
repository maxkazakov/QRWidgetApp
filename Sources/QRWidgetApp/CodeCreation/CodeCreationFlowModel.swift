
import SwiftUI
import QRWidgetCore
import QRCodeUI
import CasePaths
import SwiftUINavigation
import XCTestDynamicOverlay
import Dependencies

final class CodeCreationFlowModel: ObservableObject {

    @Dependency(\.codesService) var codesService
    @Published var utilsCodeTypes: [CodeContentType] = [CodeContentType.rawText, .url]
    @Published var contactsCodeTypes: [CodeContentType] = [CodeContentType.phone, .email]

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
            case .email:
                qrDataType = .email(EmailFormData(email: "", subject: "", message: ""))
            case .phone:
                qrDataType = .phone("")
            case .binary, .none:
                return
            }
        }
    }
    @Published var focus: CodeCreationView.Field? = .first
    @Published var navigationDestination: Destination?
    @Published var showToast = false
    var lastCreatedCodeId: UUID?

    enum Destination {
        case beautifying(BeautifyQRViewModel)
    }

    init(type: CodeContentType? = nil) {
        self.type = type
    }

    func onTapNext() {
        let codeModel = CodeModel(data: .string(qrData), type: .qr, isMy: true, qrStyle: nil)
        let viewModel = BeautifyQRViewModel(qrModel: codeModel)
        viewModel.onSaveTapped = { [weak self] code in
            self?.onTapSave(code: code)
        }
        self.navigationDestination = .beautifying(viewModel)
    }

    func onTapSave(code: CodeModel) {
        self.codesService.addNewCode(code)
        self.lastCreatedCodeId = code.id
        self.type = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.navigationDestination = nil
            self.showToast = true
        }
    }

    var goToMyCodes: () -> Void = unimplemented("goToMyCodes callback is not set")
}
