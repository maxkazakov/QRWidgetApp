import UIKit
import Contacts

public enum QRCodeType: Int, CaseIterable, Hashable, Identifiable {
    public var id: Int {
        rawValue
    }

    case rawText = 0
    case url
    case binary

    public var title: String {
        switch self {
        case .rawText:
            return L10n.rawText
        case .url:
            return L10n.website
        case .binary:
            return "Binary"
        }
    }
}

public enum QRCodeDataType {
    case rawText(String)
    case url(URL)
    case binary

    public static func make(from stringPayload: String?) -> QRCodeDataType {
        guard let stringPayload else {
            return .binary
        }
        if let url = URL(string: stringPayload), stringPayload.isValidURL {
            return .url(url)
        }
        return .rawText(stringPayload)        
    }

    public var qrString: String {
        switch self {
        case let .rawText(text):
            return text
        case let .url(url):
            return url.absoluteString
        case .binary:
            return ""
        }
    }

    public var type: QRCodeType {
        switch self {
        case .rawText:
            return .rawText
        case .url:
            return .url
        case .binary:
            return .binary
        }
    }
}

public extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}
