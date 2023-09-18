
import SwiftUI
import QRWidgetCore
import QRCodeUI
import CasePaths
import SwiftUINavigation
import XCTestDynamicOverlay
import Dependencies
import CoreLocation

final class CodeTypeRowModel: ObservableObject, Identifiable {
    init(
        navigationDestination: CodeTypeRowModel.Destination? = nil,
        type: CodeContentType
    ) {
        self.navigationDestination = navigationDestination
        self.type = type
    }

    var id: Int { type.id }

    enum Destination {
        case codeContentForm(CodeContentFormViewModel)
    }

    @Published var navigationDestination: Destination?
    let type: CodeContentType
    var onSaveCode: (CodeModel) -> Void = unimplemented("onSaveCode callback is not set")

    func setNavigationLinkActive() {
        let codeContentFormViewModel = CodeContentFormViewModel(type: type)
        codeContentFormViewModel.onSaveCode = { [weak self] code in
            self?.onSaveCode(code)
            self?.navigationDestination = nil
        }
        navigationDestination = .codeContentForm(codeContentFormViewModel)
    }
}

final class CodeTypeSelectionViewModel: ObservableObject {

    var goToMyCodes: () -> Void = unimplemented("goToMyCodes callback is not set")

    @Dependency(\.codesService) var codesService
    @Published var generalCodeTypes: [CodeTypeRowModel]
    @Published var contactsCodeTypes: [CodeTypeRowModel]
    @Published var utilsCodeTypes: [CodeTypeRowModel]
    @Published var socialsTypes: [CodeTypeRowModel]
    @Published var showToast = false

    init() {
        self.generalCodeTypes = [CodeContentType.rawText, .url].map {
            CodeTypeRowModel(type: $0)
        }
        self.contactsCodeTypes = [CodeContentType.phone, .email].map {
            CodeTypeRowModel(type: $0)
        }
        self.utilsCodeTypes = [CodeContentType.wifi, .location].map {
            CodeTypeRowModel(type: $0)
        }
        self.socialsTypes = [CodeContentType.twitter, .facebook].map {
            CodeTypeRowModel(type: $0)
        }
        (
            generalCodeTypes + contactsCodeTypes + utilsCodeTypes + socialsTypes
        ).forEach {
            $0.onSaveCode = self.onTapSave
        }
    }

    private func onTapSave(code: CodeModel) {
        self.codesService.addNewCode(code)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showToast = true
        }
    }
}
