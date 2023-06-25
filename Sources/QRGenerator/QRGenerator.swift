
import UIKit
#if !os(watchOS)
import CoreImage
import CoreImage.CIFilterBuiltins
#endif
import QRWidgetCore

let context = CIContext()
let filter = CIFilter.qrCodeGenerator()

public func generateQRCode(from string: String) -> UIImage {
    let data = Data(string.utf8)
    filter.setValue(data, forKey: "inputMessage")

    if let outputImage = filter.outputImage {
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgimg)
        }
    }

    return UIImage(systemName: "xmark.circle") ?? UIImage()
}


public extension CGColor {
    struct QRColor {
        public let defaultBackground = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        public let defaultForeground = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
    }
    static let qr = QRColor()
}


public class QRCodeGenerator {
    public static let shared = QRCodeGenerator()
    public static let defaultQRSize = CGSize(width: 300, height: 300)

    private let context = CIContext()

    public func generateQRCode(from qrModel: CodeModel, size: CGSize = QRCodeGenerator.defaultQRSize, useCustomColorsIfPossible: Bool) -> UIImage? {
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
            logoImage: nil
        )
    }

    public func generateQRCode(from string: String,
                               size: CGSize = QRCodeGenerator.defaultQRSize,
                               foreground: CGColor,
                               background: CGColor,
                               errorCorrectionLevel: String,
                               logoImage: UIImage? = nil) -> UIImage? {
        let data = Data(string.utf8)
        guard var image = createCIImage(data: data, errorCorrectionLevel: errorCorrectionLevel) else { return nil }

        if let colorImgae = updateColor(image: image, foreground: foreground, background: background) {
            image = colorImgae
        }

        print("QR original size: \(image.extent.size)")

        ///scale to width:height
        let scaleW = size.width / image.extent.size.width
        let scaleH = size.height / image.extent.size.height
        let transform = CGAffineTransform(scaleX: scaleW, y: scaleH)
        image = image.transformed(by: transform)

        if let logo = logoImage, let newImage = addLogo(image: image, logo: logo) {
            image = newImage
        }

        guard let cgimg = context.createCGImage(image, from: image.extent) else {
            return nil
        }

        return UIImage(cgImage: cgimg)
    }

    private func updateColor(image: CIImage, foreground: CGColor, background: CGColor) -> CIImage? {
        let colorFilter = CIFilter.falseColor()
        colorFilter.setValue(image, forKey: kCIInputImageKey)
        colorFilter.setValue(CIColor(cgColor: foreground), forKey: "inputColor0")
        colorFilter.setValue(CIColor(cgColor: background), forKey: "inputColor1")
        return colorFilter.outputImage
    }

    private func createCIImage(data: Data, errorCorrectionLevel: String) -> CIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.setDefaults()
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(errorCorrectionLevel, forKey: "inputCorrectionLevel")
        //https://www.qrcode.com/en/about/error_correction.html
        return filter.outputImage
    }

    private func addLogo(image: CIImage, logo: UIImage) -> CIImage? {
        guard let logo = logo.cgImage else {
            return image
        }
        let combinedFilter = CIFilter.sourceOverCompositing()
        let ciLogo = CIImage(cgImage: logo)

        let centerTransform = CGAffineTransform(translationX: image.extent.midX - (ciLogo.extent.size.width / 2), y: image.extent.midY - (ciLogo.extent.size.height / 2))

        combinedFilter.setValue(ciLogo.transformed(by: centerTransform), forKey: "inputImage")
        combinedFilter.setValue(image, forKey: "inputBackgroundImage")
        return combinedFilter.outputImage
    }
}
