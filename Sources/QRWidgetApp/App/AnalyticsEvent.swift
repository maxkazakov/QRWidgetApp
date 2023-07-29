
import Foundation

public enum AnalyticsEvent: String {
    case qrCodeRecogzined
    case qrFailedToRecognize

    // Scan
    case tapGalleryIcon
    case tapTorchIcon

    case tapCreateNewQR
    case tapCreateQRFromCamera
    case tapCreateQRFromGallery

    case startBatchScan

    // History
    case tapHistoryItem

    // Settings
    case cannotFindWidgetClick
    case howToAddButtonClick

    case tapQRLink
    case tapSettings
    case qrLabelUpdated

    // Paywall
    case paywallActivateScreenOpened
    case paywallErrorScreenOpened
    case tapRestorePurchase
    case tapActivate
    case closePaywall
    case tapOnProduct
    case tapCancelOnPaymentAlert

    case activatedSubscription
    case activatedOnetimePurchase

    case openWidgetDeeplink
    case tapContinueOnCongratsScreen

    // Tabs
    case openScanTab
    case openHistoryTab
    case openSettingsTab

    // Wallet
    case appleWalletClick
    case failedToCreateAppleWallet
    case appleWalletCreated
    case appleWalletPassAddedToLibrary
    case removePass

    // Onboarding
    case showOnboarding

    case tapContinueOnStep1
    case tapContinueOnStep2
    case tapContinueOnStep3

    case tapCloseOnPaywallOnboarding

    case openDetails
    case addToFavorites
    case removeFromFavorites

    // Beautify
    case tapChangeQRAppearance
    case tapChangeForegroundColor
    case tapChangeBackgroundColor
    case tapChangeErrorCorrectionLevel
    case tapCancelChangeQRAppearance
    case tapSaveChangeQRAppearance

    case flipQrImage

    // Share
    case tapShare
    case tapShareAsImage
    case tapShareAsString

    case asaAttribution = "ASAAttribution"
}

public enum AnalyticsSource {
    enum OpenDetails: String {
        case favorites
        case history
    }

    enum AddToFavorites: String {
        case scan
        case details
    }

    enum Share: String {
        case scan
        case details
    }

    enum QrRecognize: String {
        case camera
        case gallery
    }
}
