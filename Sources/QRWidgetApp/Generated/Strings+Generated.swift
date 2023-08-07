// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Activate
  internal static let activate = L10n.tr("Localizable", "activate")
  /// Cancel
  internal static let cancel = L10n.tr("Localizable", "cancel")
  /// Code content
  internal static let codeContent = L10n.tr("Localizable", "codeContent")
  /// Code type
  internal static let codeType = L10n.tr("Localizable", "codeType")
  /// Continue
  internal static let `continue` = L10n.tr("Localizable", "continue")
  /// Done
  internal static let done = L10n.tr("Localizable", "done")
  /// Repeat
  internal static let `repeat` = L10n.tr("Localizable", "repeat")
  /// Save
  internal static let save = L10n.tr("Localizable", "save")
  /// Select type
  internal static let selectQrType = L10n.tr("Localizable", "selectQrType")

  internal enum Allcodes {
    internal enum Segment {
      /// My
      internal static let my = L10n.tr("Localizable", "allcodes.segment.my")
      /// Scans
      internal static let scans = L10n.tr("Localizable", "allcodes.segment.scans")
    }
  }

  internal enum AppleWallet {
    /// Failed to create QR for Apple Wallet
    internal static let failedToCreatePass = L10n.tr("Localizable", "appleWallet.failedToCreatePass")
    /// Creating QR for Apple Wallet
    internal static let progress = L10n.tr("Localizable", "appleWallet.progress")
    /// QR-code added to Apple Wallet. If you add again, QR-code will be updated
    internal static let qrAlreadyAdded = L10n.tr("Localizable", "appleWallet.qrAlreadyAdded")
    /// Please try again
    internal static let tryAgain = L10n.tr("Localizable", "appleWallet.tryAgain")
  }

  internal enum ChangeAppearance {
    /// Background color
    internal static let backgroundColor = L10n.tr("Localizable", "changeAppearance.backgroundColor")
    /// Change appearance
    internal static let buttonTitle = L10n.tr("Localizable", "changeAppearance.buttonTitle")
    /// Colors
    internal static let colors = L10n.tr("Localizable", "changeAppearance.colors")
    /// Error correction level
    internal static let errorCorrectionLevel = L10n.tr("Localizable", "changeAppearance.errorCorrectionLevel")
    /// You can tap on the image to make it black and white
    internal static let fliptip = L10n.tr("Localizable", "changeAppearance.fliptip")
    /// Foreground color
    internal static let foregroundColor = L10n.tr("Localizable", "changeAppearance.foregroundColor")
    /// Appearance
    internal static let title = L10n.tr("Localizable", "changeAppearance.title")
  }

  internal enum CreateNewQrCodeButton {
    /// Create QR
    internal static let title = L10n.tr("Localizable", "createNewQrCodeButton.title")
  }

  internal enum Debug {
    internal enum Qr {
      /// Flight to London
      internal static let flight = L10n.tr("Localizable", "debug.qr.flight")
      /// Link to the app
      internal static let linkToApp = L10n.tr("Localizable", "debug.qr.linkToApp")
      /// Movie ticket
      internal static let moveTicket = L10n.tr("Localizable", "debug.qr.moveTicket")
      /// Twitter profile
      internal static let twitter = L10n.tr("Localizable", "debug.qr.twitter")
    }
  }

  internal enum DeleteQr {
    /// Remove
    internal static let buttonTitle = L10n.tr("Localizable", "deleteQr.buttonTitle")
    /// Do you want to delete QR-code?
    internal static let caution = L10n.tr("Localizable", "deleteQr.caution")
  }

  internal enum Favorites {
    internal enum Empty {
      /// You can add favorites right after scanning or from Scans tab
      internal static let subtitle = L10n.tr("Localizable", "favorites.empty.subtitle")
      /// No favorite QR-codes yet
      internal static let title = L10n.tr("Localizable", "favorites.empty.title")
    }
  }

  internal enum FlipperQr {
    internal enum Info {
      /// Tap on QR-code to see standard QR-code colors
      internal static let text = L10n.tr("Localizable", "flipperQr.info.text")
    }
  }

  internal enum Group {
    /// Group
    internal static let navigationTitle = L10n.tr("Localizable", "group.navigationTitle")
  }

  internal enum History {
    /// Batch of codes
    internal static let batch = L10n.tr("Localizable", "history.batch")
    /// Codes
    internal static let title = L10n.tr("Localizable", "history.title")
    internal enum Batch {
      /// %d QR-codes
      internal static func countOfCodes(_ p1: Int) -> String {
        return L10n.tr("Localizable", "history.batch.countOfCodes", p1)
      }
    }
    internal enum Empty {
      /// Here will be all scanned QR-codes
      internal static let subtitle = L10n.tr("Localizable", "history.empty.subtitle")
      /// No QR-codes yet
      internal static let title = L10n.tr("Localizable", "history.empty.title")
    }
  }

  internal enum MyCodes {
    internal enum Empty {
      /// Here will be QR codes created by you
      internal static let subtitle = L10n.tr("Localizable", "myCodes.empty.subtitle")
      /// You didn't create any code yet
      internal static let title = L10n.tr("Localizable", "myCodes.empty.title")
      internal enum CreateNew {
        /// Create QR
        internal static let button = L10n.tr("Localizable", "myCodes.empty.createNew.button")
      }
    }
  }

  internal enum Onboarding {
    /// All QR-codes in one place
    internal static let allQRCodesInOnePlace = L10n.tr("Localizable", "onboarding.allQRCodesInOnePlace")
    /// QR-code on main screen
    internal static let qrOnMainScreen = L10n.tr("Localizable", "onboarding.qrOnMainScreen")
    internal enum Step1 {
      /// Scan, create, customize and store all types of codes
      internal static let title = L10n.tr("Localizable", "onboarding.step1.title")
    }
    internal enum Step2 {
      /// QR codes widgets on main screen
      internal static let title = L10n.tr("Localizable", "onboarding.step2.title")
    }
    internal enum Step3 {
      /// Add to Wallet Pass and Apple Watch
      internal static let title = L10n.tr("Localizable", "onboarding.step3.title")
    }
  }

  internal enum Paywall {
    /// Free version
    internal static let freeVersion = L10n.tr("Localizable", "paywall.freeVersion")
    /// One-Time Purchase
    internal static let oneTimePurchase = L10n.tr("Localizable", "paywall.oneTimePurchase")
    /// Popular
    internal static let popular = L10n.tr("Localizable", "paywall.popular")
    /// Privacy Policy
    internal static let privacyPolicy = L10n.tr("Localizable", "paywall.privacyPolicy")
    /// Pro version
    internal static let proVersion = L10n.tr("Localizable", "paywall.proVersion")
    /// Restore
    internal static let restore = L10n.tr("Localizable", "paywall.restore")
    /// Terms of Use
    internal static let termsOfUse = L10n.tr("Localizable", "paywall.termsOfUse")
    internal enum Feature {
      internal enum AppleWallet {
        /// Easy access to your QR-codes from Apple Wallet
        internal static let subtitle = L10n.tr("Localizable", "paywall.feature.appleWallet.subtitle")
        /// Apple Wallet
        internal static let title = L10n.tr("Localizable", "paywall.feature.appleWallet.title")
      }
      internal enum AppleWatch {
        /// Add Apple Watch Complication on your Watch face to get access to QR-codes in one tap
        internal static let subtitle = L10n.tr("Localizable", "paywall.feature.appleWatch.subtitle")
        /// Apple Watch
        internal static let title = L10n.tr("Localizable", "paywall.feature.appleWatch.title")
      }
      internal enum BatchScan {
        /// Scan multiple codes at the same time without any extra steps
        internal static let subtitle = L10n.tr("Localizable", "paywall.feature.batchScan.subtitle")
        /// Batch scan
        internal static let title = L10n.tr("Localizable", "paywall.feature.batchScan.title")
      }
      internal enum Customization {
        /// Change QR-codes colors, adjust error correction level
        internal static let subtitle = L10n.tr("Localizable", "paywall.feature.customization.subtitle")
        /// Customization
        internal static let title = L10n.tr("Localizable", "paywall.feature.customization.title")
      }
      internal enum NoAds {
        /// Enjoy the app without being interrupted by ads
        internal static let subtitle = L10n.tr("Localizable", "paywall.feature.noAds.subtitle")
        /// No ads
        internal static let title = L10n.tr("Localizable", "paywall.feature.noAds.title")
      }
      internal enum Scanner {
        /// Use camera or photos to add new QR-code
        internal static let subtitle = L10n.tr("Localizable", "paywall.feature.scanner.subtitle")
        /// Scanner
        internal static let title = L10n.tr("Localizable", "paywall.feature.scanner.title")
      }
      internal enum Sharing {
        /// Export QR-codes as text or image
        internal static let subtitle = L10n.tr("Localizable", "paywall.feature.sharing.subtitle")
        /// Share
        internal static let title = L10n.tr("Localizable", "paywall.feature.sharing.title")
      }
      internal enum Widgets {
        /// Add QR-codes on main screen of your iPhone to get fastest access
        internal static let subtitle = L10n.tr("Localizable", "paywall.feature.widgets.subtitle")
        /// Widgets
        internal static let title = L10n.tr("Localizable", "paywall.feature.widgets.title")
      }
    }
    internal enum Plan {
      /// Then %@ / %@
      internal static func thenPrice(_ p1: Any, _ p2: Any) -> String {
        return L10n.tr("Localizable", "paywall.plan.thenPrice", String(describing: p1), String(describing: p2))
      }
      internal enum Introductory {
        /// %@ Free
        internal static func free(_ p1: Any) -> String {
          return L10n.tr("Localizable", "paywall.plan.introductory.free", String(describing: p1))
        }
        /// %@ for %@
        internal static func periodAndPrice(_ p1: Any, _ p2: Any) -> String {
          return L10n.tr("Localizable", "paywall.plan.introductory.periodAndPrice", String(describing: p1), String(describing: p2))
        }
      }
    }
  }

  internal enum Qr {
    /// No name
    internal static let noname = L10n.tr("Localizable", "qr.noname")
  }

  internal enum QrDetails {
    /// Add to Favorites
    internal static let addToFavorites = L10n.tr("Localizable", "qrDetails.addToFavorites")
    /// Apple Wallet Pass
    internal static let appleWalletPass = L10n.tr("Localizable", "qrDetails.appleWalletPass")
    /// Remove from favorites
    internal static let removeFromFavorites = L10n.tr("Localizable", "qrDetails.removeFromFavorites")
    /// Details
    internal static let title = L10n.tr("Localizable", "qrDetails.title")
    internal enum Name {
      /// You may name QR, e.g. Movie ticket
      internal static let placeholder = L10n.tr("Localizable", "qrDetails.name.placeholder")
    }
  }

  internal enum QrStyle {
    /// Eye
    internal static let eye = L10n.tr("Localizable", "qrStyle.eye")
    /// Pixels
    internal static let pixels = L10n.tr("Localizable", "qrStyle.pixels")
  }

  internal enum QrType {
    /// Text
    internal static let text = L10n.tr("Localizable", "qrType.text")
    /// Website
    internal static let website = L10n.tr("Localizable", "qrType.website")
  }

  internal enum Scanner {
    /// Code was not found
    internal static let qrNotFound = L10n.tr("Localizable", "scanner.qrNotFound")
    /// Batch Scan
    internal static let scanButton = L10n.tr("Localizable", "scanner.scanButton")
    /// Scanned %d
    internal static func scannedCount(_ p1: Int) -> String {
      return L10n.tr("Localizable", "scanner.scannedCount", p1)
    }
    /// Start
    internal static let startButton = L10n.tr("Localizable", "scanner.startButton")
    /// Stop
    internal static let stopButton = L10n.tr("Localizable", "scanner.stopButton")
    internal enum About {
      /// Use this mode when you want to scan many QR-codes one by one. Scanned codes will be shown as group on History tab
      internal static let subtitle = L10n.tr("Localizable", "scanner.about.subtitle")
      /// About batch scan
      internal static let title = L10n.tr("Localizable", "scanner.about.title")
    }
    internal enum Result {
      /// Scan Result
      internal static let title = L10n.tr("Localizable", "scanner.result.title")
    }
  }

  internal enum Settings {
    /// Contact Developer
    internal static let contactDeveloper = L10n.tr("Localizable", "settings.contactDeveloper")
    /// FAQ
    internal static let faq = L10n.tr("Localizable", "settings.faq")
    /// General
    internal static let general = L10n.tr("Localizable", "settings.general")
    /// How to add widget?
    internal static let howToAddWidget = L10n.tr("Localizable", "settings.howToAddWidget")
    /// Scanner
    internal static let scanner = L10n.tr("Localizable", "settings.scanner")
    /// Settings
    internal static let title = L10n.tr("Localizable", "settings.title")
    /// Vibration
    internal static let vibration = L10n.tr("Localizable", "settings.vibration")
    /// Write Review
    internal static let writeReview = L10n.tr("Localizable", "settings.writeReview")
    internal enum BugWithWidget {
      /// Unfortunately, this is a bug in iOS. Restart your phone, then open the app. After that, the widget will appear in widget gallery
      internal static let answer = L10n.tr("Localizable", "settings.bugWithWidget.answer")
      /// I cannot find widget in widget gallery
      internal static let question = L10n.tr("Localizable", "settings.bugWithWidget.question")
    }
    internal enum Pro {
      /// Activate more features for your QR-codes
      internal static let describtion = L10n.tr("Localizable", "settings.pro.describtion")
      /// Pro version
      internal static let title = L10n.tr("Localizable", "settings.pro.title")
    }
  }

  internal enum Sharing {
    /// Image
    internal static let asImage = L10n.tr("Localizable", "sharing.asImage")
    /// PDF
    internal static let asPdf = L10n.tr("Localizable", "sharing.asPdf")
    /// Text
    internal static let asText = L10n.tr("Localizable", "sharing.asText")
    /// Share
    internal static let title = L10n.tr("Localizable", "sharing.title")
  }

  internal enum ShowDetails {
    internal enum Button {
      /// Show details
      internal static let title = L10n.tr("Localizable", "showDetails.button.title")
    }
  }

  internal enum StartScanningButton {
    /// Start Scanning
    internal static let title = L10n.tr("Localizable", "startScanningButton.title")
  }

  internal enum Subscription {
    /// You have unlocked Pro version!
    internal static let activated = L10n.tr("Localizable", "subscription.activated")
    /// Subscription expired
    internal static let expired = L10n.tr("Localizable", "subscription.expired")
  }

  internal enum Tabs {
    /// Favorites
    internal static let favorites = L10n.tr("Localizable", "tabs.favorites")
    /// History
    internal static let history = L10n.tr("Localizable", "tabs.history")
    /// Scan
    internal static let scan = L10n.tr("Localizable", "tabs.scan")
    /// Settings
    internal static let settings = L10n.tr("Localizable", "tabs.settings")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
