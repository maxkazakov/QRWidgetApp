import UIKit
import Contacts

public enum CodeContentType: Int, CaseIterable, Hashable, Identifiable {
    public var id: Int {
        rawValue
    }

    case rawText = 0
    case url
    case phone
    case email
    case binary
    case location

    public var title: String {
        switch self {
        case .rawText:
            return L10n.rawText
        case .url:
            return L10n.website
        case .phone:
            return "Phone"
        case .email:
            return "Email"
        case .binary:
            return "Binary"
        case .location:
            return "Location"
        }
    }
}

public enum CodeContent {
    case rawText(String)
    case url(URL)
    case phone(URL)
    case email(URL)
    case binary
    case location(URL)

    public static func make(from stringPayload: String?) -> CodeContent {
        guard var stringPayload else {
            return .binary
        }
        stringPayload = stringPayload.trimmingCharacters(in: .whitespacesAndNewlines)

        if stringPayload.hasPrefix(CodeContentConstants.tel), let phoneUrl = URL(string: stringPayload) {
            return .phone(phoneUrl)
        }

        if stringPayload.hasPrefix(CodeContentConstants.mailto), let emailUrl = URL(string: stringPayload) {
            return .email(emailUrl)
        }

        if stringPayload.hasPrefix("https://maps.google.com/local?q="), let geoUrl = URL(string: stringPayload) {
            return .location(geoUrl)
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
        case let .phone(phone):
            return phone.absoluteString
        case let .email(email):
            return email.absoluteString
        case let .location(geoUrl):
            return geoUrl.absoluteString
        }
    }

    public var type: CodeContentType {
        switch self {
        case .rawText:
            return .rawText
        case .url:
            return .url
        case .binary:
            return .binary
        case .phone:
            return .phone
        case .email:
            return .email
        case .location:
            return .location
        }
    }
}

//CodeContent

private struct CodeContentConstants {
    static let tel = "tel:"
    static let mailto = "mailto:"
    static let geo = "geo:"
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
