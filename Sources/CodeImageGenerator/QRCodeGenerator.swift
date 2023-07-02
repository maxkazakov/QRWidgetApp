import Foundation
import Dependencies
import QRCode
import QRWidgetCore
import UIKit

struct QRCodeStyle {
    
}

struct QRCodeImageGenerationInfo {
    let data: String
    let size: CGSize
    let errorCorrectessLevel: ErrorCorrection
    let style: QRCodeStyle
}

struct QRCodeGenerator {
    var generateImage: (_ info: QRCodeImageGenerationInfo) -> UIImage
}

extension QRCodeGenerator {
    static let live: QRCodeGenerator = {
        QRCodeGenerator(generateImage: { info in
            let doc = QRCode.Document(utf8String: info.data)
            doc.errorCorrection = info.errorCorrectessLevel.toQRCodeErrorCorrection()
            let generated = doc.uiImage(info.size)
            return generated!
        })
    }()
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
