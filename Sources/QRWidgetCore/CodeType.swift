
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
}
