import Foundation
import QRWidgetCore

enum QRFormData {
    case rawText(String)
    case url(String)
    case email(EmailFormData)
    case phone(String)
    case location(LocationFormData)
    case wifi(WifiFormData)

    var isValid: Bool {
        qrData() != nil
    }

    func qrData() -> CodeContent? {
        switch self {
        case let .rawText(text):
            if text.isEmpty {
                return nil
            }
            return .rawText(text)
        case let .url(urlString):
            guard let url = URL(string: urlString), urlString.isValidURL else { return nil }
            return .url(url)

        case let .phone(phone):
            guard let phoneURL = URL(string: "tel:\(phone)") else { return nil }
            return .phone(phoneURL)

        case let .email(emailFormData):
            guard isValidEmail(emailFormData.email) else {
                return nil
            }
            guard var components = URLComponents(string: emailFormData.email) else {
                return nil
            }
            var parameters: [URLQueryItem] = []
            if !emailFormData.subject.isEmpty {
                parameters.append(URLQueryItem(name: "subject", value: emailFormData.subject))
            }
            if !emailFormData.message.isEmpty {
                parameters.append(URLQueryItem(name: "body", value: emailFormData.message))
            }
            if !parameters.isEmpty {
                components.queryItems = parameters
            }
            components.scheme = "mailto"
            guard let fullEmailUrl = components.url else {
                return nil
            }
            return .email(fullEmailUrl)

        case let .location(locationFormData):
            if locationFormData.latitude.isZero || locationFormData.longitude.isZero {
                return nil
            }
            guard let latitudeString = Self.locationFormatter.string(from: NSNumber(value: locationFormData.latitude)),
                  let longitudeString = Self.locationFormatter.string(from: NSNumber(value: locationFormData.longitude)) else {
                return nil
            }

            guard let geoURL = URL(string: "https://maps.google.com/local?q=\(latitudeString),\(longitudeString)") else { return nil }
            return .location(geoURL)

        case let .wifi(wifiData):
            return .wifi("WIFI:S:\(wifiData.ssid);T:\(wifiData.encryption.rawValue);P:\(wifiData.password);;")

        }
    }

    static let locationFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = 10
        return formatter
    }()
}

struct EmailFormData {
    var email: String
    var subject: String
    var message: String
}

struct LocationFormData {
    var latitude: Double
    var longitude: Double
}

typealias WifiFormData = WifiData

func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}
