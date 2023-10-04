
import Foundation
import AVFoundation

public enum CodeType: Int, Codable {
    case qr
    case aztec
    case ean13
    case ean8
    case code128
    case code39
    case code39Mod43
    case pdf417

    public var description: String {
        switch self {
        case .qr:
            return "qr"
        case .aztec:
            return "aztec"
        case .ean13:
            return "ean13"
        case .ean8:
            return "ean8"
        case .code128:
            return "code128"
        case .code39:
            return "code39"
        case .code39Mod43:
            return "code39Mod43"
        case .pdf417:
            return "pdf417"
        }
    }
}
