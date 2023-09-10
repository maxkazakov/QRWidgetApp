
import SwiftUI
import QRWidgetCore
import QRCodeUI
import CasePaths
import SwiftUINavigation
import XCTestDynamicOverlay
import Dependencies
import CoreLocation

final class CodeTypeSelectionViewModel: ObservableObject {

    var goToMyCodes: () -> Void = unimplemented("goToMyCodes callback is not set")

    @Dependency(\.codesService) var codesService
    @Published var utilsCodeTypes: [CodeContentType] = [CodeContentType.rawText, .url]
    @Published var contactsCodeTypes: [CodeContentType] = [CodeContentType.phone, .email, .location]

    @Published var navigationDestination: Destination?
    @Published var showToast = false

    enum Destination {
        case codeContentForm(CodeContentFormViewModel)
    }

    func setNavigationLinkActive(_ isActive: Bool, type: CodeContentType) {
        if isActive {
            let codeContentFormViewModel = CodeContentFormViewModel(type: type)
            codeContentFormViewModel.onSaveCode = { [weak self] code in
                self?.onTapSave(code: code)
            }
            navigationDestination = .codeContentForm(codeContentFormViewModel)
        } else {
            navigationDestination = nil
        }
    }

    private func onTapSave(code: CodeModel) {
        self.codesService.addNewCode(code)
        self.navigationDestination = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.navigationDestination = nil
            self.showToast = true
        }
    }
}
