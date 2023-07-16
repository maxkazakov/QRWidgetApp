import Foundation
import Dependencies
import QRCode
import QRWidgetCore
import UIKit

struct QRCodeImageGenerationInfo {
    let data: String
    let size: CGSize
    let errorCorrectessLevel: ErrorCorrection
    let foregroundColor: CGColor
    let backgroundColor: CGColor
    let qrStyle: QRStyle?
}

struct QRCodeGenerator {
    var generateImage: (_ info: QRCodeImageGenerationInfo) -> UIImage
}

extension QRCodeGenerator {
    static let live: QRCodeGenerator = {
        QRCodeGenerator(generateImage: { info in
            let doc = QRCode.Document(utf8String: info.data)
            doc.errorCorrection = info.errorCorrectessLevel.toQRCodeErrorCorrection()
            doc.design.style.onPixels = QRCode.FillStyle.Solid(info.foregroundColor)
            doc.design.backgroundColor(info.backgroundColor)

            if let qrStyle = info.qrStyle {
                doc.applyStyle(qrStyle)
            }

            let generated = doc.uiImage(info.size)
            return generated!
        })
    }()
}

private extension QRCode.Document {
    func applyStyle(_ qrStyle: QRStyle) {
        func getEyeType() -> QRCodeEyeShapeGenerator {
            switch qrStyle.eye {
            case .square:
                return QRCode.EyeShape.Square()
            case .circle:
                return QRCode.EyeShape.Circle()
            case .roundedRect:
                return QRCode.EyeShape.RoundedRect()
            case .roundedOuter:
                return QRCode.EyeShape.RoundedOuter()
            case .roundedPointingIn:
                return QRCode.EyeShape.RoundedPointingIn()
            case .leaf:
                return QRCode.EyeShape.Leaf()
            case .squircle:
                return QRCode.EyeShape.Squircle()
            case .barsHorizontal:
                return QRCode.EyeShape.BarsHorizontal()
            case .barsVertical:
                return QRCode.EyeShape.BarsVertical()
            case .pixels:
                return QRCode.EyeShape.Pixels()
            case .corneredPixels:
                return QRCode.EyeShape.CorneredPixels()
            case .edges:
                return QRCode.EyeShape.Edges()
            case .shield:
                return QRCode.EyeShape.Shield()
            }
        }

        func getOnPixelsType() -> QRCodePixelShapeGenerator {
            switch qrStyle.onPixels {
            case .square: return QRCode.PixelShape.Square()
            case .circle: return QRCode.PixelShape.Circle()
            case .curvePixel: return QRCode.PixelShape.CurvePixel()
            case .roundedPath: return QRCode.PixelShape.RoundedPath()
            case .roundedEndIndent: return QRCode.PixelShape.RoundedEndIndent()
            case .squircle: return QRCode.PixelShape.Squircle()
            case .pointy: return QRCode.PixelShape.Pointy()
            case .sharp: return QRCode.PixelShape.Sharp()
            case .star: return QRCode.PixelShape.Star()
            case .flower: return QRCode.PixelShape.Flower()
            case .shiny: return QRCode.PixelShape.Shiny()
            }
        }

        design.shape.eye = getEyeType()
        design.shape.onPixels = getOnPixelsType()
    }
}

extension ErrorCorrection {
    func toQRCodeErrorCorrection() -> QRCode.ErrorCorrection {
        switch self {
        case .H: return .high
        case .L: return .low
        case .M: return .medium
        case .Q: return .quantize
        }
    }
}
