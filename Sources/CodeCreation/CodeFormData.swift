import Foundation
import QRWidgetCore

enum QRFormData {
    case rawText(String)
    case url(String)

    var isValid: Bool {
        qrData() != nil
    }

    func qrData() -> QRCodeDataType? {
        switch self {
        case let .rawText(text):
            if text.isEmpty {
                return nil
            }
            return .rawText(text)
        case let .url(urlString):
            guard let url = URL(string: urlString), urlString.isValidURL else { return nil }
            return .url(url)
        }
    }
}
