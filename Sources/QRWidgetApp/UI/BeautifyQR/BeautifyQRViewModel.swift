
import SwiftUI
import QRWidgetCore
import CodeImageGenerator
import XCTestDynamicOverlay
import Dependencies

class BeautifyQRViewModel: ViewModel {

    @Dependency(\.codesService) var codesService
    private let sendAnalytics: SendAnalyticsAction

    var onSaveTapped: (_ codeModel: CodeModel) -> Void = unimplemented()

    public init(
        qrModel: CodeModel,
        sendAnalytics: @escaping SendAnalyticsAction
    ) {
        self.sendAnalytics = sendAnalytics

        self.qrModel = qrModel
        self.foregroundColor = qrModel.foregroundColor?.cgColor ?? .qr.defaultForeground
        self.backgroundColor = qrModel.backgroundColor?.cgColor ?? .qr.defaultBackground
        self.errorCorrectionLevel = qrModel.errorCorrectionLevel

        self.qrStyle = qrModel.qrStyle ?? QRStyle()

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
    @Published var qrStyle: QRStyle

    @Published var errorCorrectionLevel: ErrorCorrection {
        didSet {
            sendAnalytics(.tapChangeErrorCorrectionLevel, ["level": errorCorrectionLevel.title])
        }
    }

    var showQRSpecificSettings: Bool {
        qrModel.data.stringPayload != nil && qrModel.type == .qr
    }

    func save() {
        sendAnalytics(.tapSaveChangeQRAppearance, nil)

        if isProActivated {
            saveChanges()            
        } else if checkIfProFeaturesChanged() {
            showPaywall = true
        } else {
            saveChanges()
        }
    }

    private func saveChanges() {
        var newCodeModel = qrModel
        newCodeModel.errorCorrectionLevel = errorCorrectionLevel
        newCodeModel.foregroundColor = isForegroundColorStayedDefault ? nil : UIColor(cgColor: self.foregroundColor)
        newCodeModel.backgroundColor = isBackgroundColorStayedDefault ? nil : UIColor(cgColor: self.backgroundColor)
        newCodeModel.qrStyle = qrStyle

        onSaveTapped(newCodeModel)
    }

    private var isForegroundColorStayedDefault: Bool {
        foregroundColor == .qr.defaultForeground
    }

    private var isBackgroundColorStayedDefault: Bool {
        backgroundColor == .qr.defaultBackground
    }

    func checkIfProFeaturesChanged() -> Bool {
        let isColorDefault = foregroundColor == CGColor.qr.defaultForeground
            && backgroundColor == CGColor.qr.defaultBackground
        let isCorectionLevelDefault = errorCorrectionLevel == .default
        let isDefaultQRStyle = qrStyle.isDefault
        let nothingChanged = isColorDefault
            && isCorectionLevelDefault
            && isDefaultQRStyle
        return !nothingChanged
    }
}
