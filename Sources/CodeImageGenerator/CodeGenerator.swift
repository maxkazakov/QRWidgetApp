
import UIKit
#if !os(watchOS)
import CoreImage
import CoreImage.CIFilterBuiltins
#endif
import QRWidgetCore

public class CodeGenerator {
    public static let shared = CodeGenerator()
    public static let defaultQRSize = CGSize(width: 300, height: 300)

    private let context = CIContext()

    public func generateQRCode(
        from qrModel: CodeModel,
        size: CGSize = CodeGenerator.defaultQRSize,
        useCustomColorsIfPossible: Bool
    ) -> UIImage? {
        let foregroundColor = useCustomColorsIfPossible
        ? (qrModel.foregroundColor?.cgColor ?? CGColor.qr.defaultForeground)
        : CGColor.qr.defaultForeground

        let backgroundColor = useCustomColorsIfPossible
        ? (qrModel.backgroundColor?.cgColor ?? CGColor.qr.defaultBackground)
        : CGColor.qr.defaultBackground

        return generateQRCode(
            from: qrModel.data,
            size: size,
            foreground: foregroundColor,
            background: backgroundColor,
            errorCorrectionLevel: qrModel.errorCorrectionLevel.rawValue,
            codeType: qrModel.type,
            logoImage: nil
        )
    }

    public func generateQRCode(
        from codeData: CodeModel.DataType,
        size: CGSize = CodeGenerator.defaultQRSize,
        foreground: CGColor,
        background: CGColor,
        errorCorrectionLevel: String,
        codeType: CodeType,
        logoImage: UIImage? = nil
    ) -> UIImage? {
        let filter: CIFilter?
        switch codeData {
        case let .combined(_, descriptor), let .descriptor(descriptor):
            filter = makeCIFilter(inputBarcodeDescriptor: descriptor)

        case let .string(stringPayload):
            let data = Data(stringPayload.utf8)
            filter = makeCIFilter(data: data, codeType: codeType)
        }

        guard let filter else { return nil }
        applyCorrectionLevel(filter: filter, codeType: codeType, errorCorrectionLevel: errorCorrectionLevel)
        return filter.outputImage.flatMap {
            convertToImage(ciImage: $0, size: size, foreground: foreground, background: background)
        }
    }

    // MARK: - Private

    private func updateColor(image: CIImage, foreground: CGColor, background: CGColor) -> CIImage? {
        let colorFilter = CIFilter.falseColor()
        colorFilter.inputImage = image
        colorFilter.color0 = CIColor(cgColor: foreground)
        colorFilter.color1 = CIColor(cgColor: background)
        return colorFilter.outputImage
    }

    private func makeCIFilter(data: Data, codeType: CodeType) -> CIFilter? {
        switch codeType {
        case .qr:
            let filter = CIFilter.qrCodeGenerator()
            filter.setDefaults()
            filter.message = data
            return filter

        case .aztec:
            let filter = CIFilter.aztecCodeGenerator()
            filter.setDefaults()
            filter.message = data
            return filter
        }
    }

    private func makeCIFilter(inputBarcodeDescriptor: CIBarcodeDescriptor) -> CIFilter? {
        guard let filter = CIFilter(name: "CIBarcodeGenerator") else {
            return nil
        }
        filter.setDefaults()
        filter.setValue(inputBarcodeDescriptor, forKey: "inputBarcodeDescriptor")
        return filter
    }

    private func applyCorrectionLevel<FilterType: CIFilter>(filter: FilterType, codeType: CodeType, errorCorrectionLevel: String) {
        switch codeType {
        case .qr:
            //https://www.qrcode.com/en/about/error_correction.html
            filter.setValue(errorCorrectionLevel, forKey: "inputCorrectionLevel")
        case .aztec:
            // TODO: Add Correctness level support:
            // https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIAztecCodeGenerator
            //            filter.setValue(errorCorrectionLevel, forKey: "inputCorrectionLevel")
            break
        }
    }

    private func convertToImage(ciImage: CIImage, size: CGSize, foreground: CGColor, background: CGColor) -> UIImage? {
        var resultImage = ciImage
        if let colorImage = updateColor(image: ciImage, foreground: foreground, background: background) {
            resultImage = colorImage
        }

        print("QR original size: \(resultImage.extent.size)")

        ///scale to width:height
        let scaleW = size.width / resultImage.extent.size.width
        let scaleH = size.height / resultImage.extent.size.height
        let transform = CGAffineTransform(scaleX: scaleW, y: scaleH)
        resultImage = resultImage.transformed(by: transform)

        guard let cgimg = context.createCGImage(resultImage, from: resultImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgimg)
    }
}

public extension CGColor {
    struct QRColor {
        public let defaultBackground = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        public let defaultForeground = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
    }
    static let qr = QRColor()
}
