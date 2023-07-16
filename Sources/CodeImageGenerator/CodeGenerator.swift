
import UIKit
#if !os(watchOS)
import CoreImage
import CoreImage.CIFilterBuiltins
#endif
import QRWidgetCore
import Dependencies

public struct CodeGenerator {
    public var generateCode: (
        _ codeType: CodeModel.DataType,
        _ size: CGSize,
        _ foreground: CGColor,
        _ background: CGColor,
        _ errorCorrectionLevel: ErrorCorrection,
        _ codeType: CodeType,
        _ qrStyle: QRStyle?
    ) -> UIImage?
}

// MARK: - Helpers

public extension CodeGenerator {
    func generateCodeFromModel(
        _ model: CodeModel,
        _ size: CGSize,
        _ useCustomColorsIfPossible: Bool
    ) -> UIImage? {
        let foregroundColor = useCustomColorsIfPossible
        ? (model.foregroundColor?.cgColor ?? CGColor.qr.defaultForeground)
        : CGColor.qr.defaultForeground

        let backgroundColor = useCustomColorsIfPossible
        ? (model.backgroundColor?.cgColor ?? CGColor.qr.defaultBackground)
        : CGColor.qr.defaultBackground

        let style: QRStyle? = useCustomColorsIfPossible
        ? model.qrStyle
        : nil

        return generateCode(
            model.data,
            size,
            foregroundColor,
            backgroundColor,
            model.errorCorrectionLevel,
            model.type,
            style
        )
    }

    func generateCodeFromModel(
        _ model: CodeModel,
        _ useCustomColorsIfPossible: Bool
    ) -> UIImage? {
        self.generateCodeFromModel(model, CodeGeneratorLive.defaultQRSize, useCustomColorsIfPossible)
    }

    func generateCode(
        _ data: CodeModel.DataType,
        _ foreground: CGColor,
        _ background: CGColor,
        _ errorCorrectionLevel: ErrorCorrection,
        _ codeType: CodeType,
        _ qrStyle: QRStyle?
    ) -> UIImage? {
        self.generateCode(
            data,
            CodeGeneratorLive.defaultQRSize,
            foreground,
            background,
            errorCorrectionLevel,
            codeType,
            qrStyle
        )
    }
}

public extension DependencyValues {
    var codeGenerator: CodeGenerator {
        get { self[CodesGeneratorKey.self] }
        set { self[CodesGeneratorKey.self] = newValue }
    }
}

public enum CodesGeneratorKey: DependencyKey {
    public static let liveValue = CodeGenerator.live
}
