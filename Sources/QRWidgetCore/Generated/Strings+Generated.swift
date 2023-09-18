// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Text
  internal static let rawText = L10n.tr("Localizable", "rawText")
  /// Website
  internal static let website = L10n.tr("Localizable", "website")

  internal enum QrStyle {
    internal enum Eye {
      /// Bars horizontal
      internal static let barsHorizontal = L10n.tr("Localizable", "qrStyle.eye.barsHorizontal")
      /// Bars vertical
      internal static let barsVertical = L10n.tr("Localizable", "qrStyle.eye.barsVertical")
      /// Circle
      internal static let circle = L10n.tr("Localizable", "qrStyle.eye.circle")
      /// Cornered pixels
      internal static let corneredPixels = L10n.tr("Localizable", "qrStyle.eye.corneredPixels")
      /// Edges
      internal static let edges = L10n.tr("Localizable", "qrStyle.eye.edges")
      /// Leaf
      internal static let leaf = L10n.tr("Localizable", "qrStyle.eye.leaf")
      /// Pixels
      internal static let pixels = L10n.tr("Localizable", "qrStyle.eye.pixels")
      /// Rounded outer
      internal static let roundedOuter = L10n.tr("Localizable", "qrStyle.eye.roundedOuter")
      /// Rounded pointing in
      internal static let roundedPointingIn = L10n.tr("Localizable", "qrStyle.eye.roundedPointingIn")
      /// Rounded rectangle
      internal static let roundedRect = L10n.tr("Localizable", "qrStyle.eye.roundedRect")
      /// Shield
      internal static let shield = L10n.tr("Localizable", "qrStyle.eye.shield")
      /// Square
      internal static let square = L10n.tr("Localizable", "qrStyle.eye.square")
      /// Squircle
      internal static let squircle = L10n.tr("Localizable", "qrStyle.eye.squircle")
    }
    internal enum Pixels {
      /// Circle
      internal static let circle = L10n.tr("Localizable", "qrStyle.pixels.circle")
      /// Curve pixel
      internal static let curvePixel = L10n.tr("Localizable", "qrStyle.pixels.curvePixel")
      /// Flower
      internal static let flower = L10n.tr("Localizable", "qrStyle.pixels.flower")
      /// Pointy
      internal static let pointy = L10n.tr("Localizable", "qrStyle.pixels.pointy")
      /// Rounded end indent
      internal static let roundedEndIndent = L10n.tr("Localizable", "qrStyle.pixels.roundedEndIndent")
      /// Rounded path
      internal static let roundedPath = L10n.tr("Localizable", "qrStyle.pixels.roundedPath")
      /// Sharp
      internal static let sharp = L10n.tr("Localizable", "qrStyle.pixels.sharp")
      /// Shiny
      internal static let shiny = L10n.tr("Localizable", "qrStyle.pixels.shiny")
      /// Square
      internal static let square = L10n.tr("Localizable", "qrStyle.pixels.square")
      /// Squircle
      internal static let squircle = L10n.tr("Localizable", "qrStyle.pixels.squircle")
      /// Star
      internal static let star = L10n.tr("Localizable", "qrStyle.pixels.star")
    }
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
