
import SwiftUI
import QRWidgetCore
import QRCodeUI
import CasePaths
import SwiftUINavigation
import XCTestDynamicOverlay
import Dependencies
import CoreLocation

final class CodeContentFormViewModel: ObservableObject {

    var onSaveCode: (CodeModel) -> Void = unimplemented("onSaveCode callback is not set")

    @Published var qrFormData: QRFormData = .rawText("") {
        didSet {
            guard let qrdata = qrFormData.qrData() else {
                self.canCreate = false
                return
            }
            self.codeStringPayload = qrdata.qrString
            self.canCreate = true
        }
    }
    @Published var canCreate = false
    @Published var focus: CodeContentFormView.Field? = .first
    @Published var navigationDestination: Destination?

    private var codeStringPayload: String = ""

    enum Destination {
        case beautifying(BeautifyQRViewModel)
    }

    init(type: CodeContentType? = nil) {
        focus = .first
        switch type {
        case .url:
            qrFormData = .url("https://")
        case .rawText:
            qrFormData = .rawText("")
        case .email:
            qrFormData = .email(EmailFormData(email: "", subject: "", message: ""))
        case .phone:
            qrFormData = .phone("")
        case .location:
            qrFormData = .location(.init(latitude: .zero, longitude: .zero))
        case .wifi:
            qrFormData = .wifi(WifiFormData(ssid: "", password: "", encryption: .nopass))
        case .binary, .none:
            return
        }
    }

    func onTapNext() {
        let codeModel = CodeModel(data: .string(codeStringPayload), type: .qr, isMy: true, qrStyle: nil)
        let viewModel = BeautifyQRViewModel(qrModel: codeModel)
        viewModel.onSaveTapped = { [weak self] code in
            self?.onSaveCode(code)
        }
        self.navigationDestination = .beautifying(viewModel)
    }
}
