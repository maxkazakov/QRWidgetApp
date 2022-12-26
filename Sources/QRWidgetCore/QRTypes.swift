import UIKit
import Contacts

public enum QRCodeType: Int, CaseIterable {
    case rawText = 0
    case url

    public var title: String {
        switch self {
        case .rawText:
            return "Raw text"
        case .url:
            return "Website"
        }
    }
}

public enum QRCodeDataType {
    case rawText(String)
    case url(URL)

    public static func make(from string: String) -> QRCodeDataType {
        if let url = URL(string: string), string.isValidURL {
            return .url(url)
        }
        return .rawText(string)
    }

    public var qrString: String {
        switch self {
        case let .rawText(text):
            return text
        case let .url(url):
            return url.absoluteString
        }
    }

    public var type: QRCodeType {
        switch self {
        case .rawText:
            return .rawText
        case .url:
            return .url
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
