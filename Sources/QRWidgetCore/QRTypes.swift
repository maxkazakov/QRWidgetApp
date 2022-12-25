import UIKit
import Contacts

public enum QRCodeType: Int, Identifiable, CaseIterable {
    public var id: Int {
        self.rawValue
    }
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
        if let url = URL(string: string), string.hasPrefix("http") || string.hasPrefix("www") {
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

