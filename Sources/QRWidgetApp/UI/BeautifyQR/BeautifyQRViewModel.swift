
import SwiftUI
import QRWidgetCore
import QRGenerator
import Dependencies

class BeautifyQRViewModel: ViewModel {

    @Dependency(\.codesService) var codesService
    private let sendAnalytics: SendAnalyticsAction

    public init(
        qrModel: CodeModel,
        sendAnalytics: @escaping SendAnalyticsAction
    ) {
        self.sendAnalytics = sendAnalytics

        self.qrModel = qrModel
        self.foregroundColor = qrModel.foregroundColor?.cgColor ?? .qr.defaultForeground
        self.backgroundColor = qrModel.backgroundColor?.cgColor ?? .qr.defaultBackground
        self.errorCorrectionLevel = qrModel.errorCorrectionLevel
        super.init()

        $backgroundColor
            .dropFirst()
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink(receiveValue: { _ in
                sendAnalytics(.tapChangeBackgroundColor, nil)
            })
            .store(in: &cancellableSet)

        $foregroundColor
            .dropFirst()
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink(receiveValue: { _ in
                sendAnalytics(.tapChangeForegroundColor, nil)
            })
            .store(in: &cancellableSet)
    }

    @Published var needToClose = false
    @Published var showPaywall: Bool = false

    let qrModel: CodeModel

    @Published var foregroundColor: CGColor
    @Published var backgroundColor: CGColor

    @Published var errorCorrectionLevel: ErrorCorrection {
        didSet {
            sendAnalytics(.tapChangeErrorCorrectionLevel, ["level": errorCorrectionLevel.title])
        }
    }

    func cancel() {
        router.dismissByItself(completion: nil)
        sendAnalytics(.tapCancelChangeQRAppearance, nil)
    }

    func save() {
        sendAnalytics(.tapSaveChangeQRAppearance, nil)

        if isProActivated {
            saveChanges()
            router.dismissByItself(completion: nil)
        } else if checkIfProFeaturesChanged() {
            showPaywall = true
        } else {
            saveChanges()
            router.dismissByItself(completion: nil)
        }
    }

    private func saveChanges() {
        codesService.changeQRAppearance(
            qrModel.id,
            errorCorrectionLevel,
            isForegroundColorStayedDefault ? nil : UIColor(cgColor: self.foregroundColor),
            isBackgroundColorStayedDefault ? nil : UIColor(cgColor: self.backgroundColor)
        )
    }

    private var isForegroundColorStayedDefault: Bool {
        foregroundColor == .qr.defaultForeground
    }

    private var isBackgroundColorStayedDefault: Bool {
        backgroundColor == .qr.defaultBackground
    }

    private func checkIfProFeaturesChanged() -> Bool {
        let isColorDefault = foregroundColor == CGColor.qr.defaultForeground
            && backgroundColor == CGColor.qr.defaultBackground
        let isCoorectionLevelDefault = errorCorrectionLevel == .default
        let nothingChanged = isColorDefault && isCoorectionLevelDefault
        return !nothingChanged
    }
}
