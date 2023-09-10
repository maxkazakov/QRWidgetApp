
import Foundation
import NetworkExtension

public struct WifiData {
    public init(ssid: String, password: String, encryption: WifiData.Encryption) {
        self.ssid = ssid
        self.password = password
        self.encryption = encryption
    }

    public enum Encryption: String, CaseIterable, Identifiable {

        public var id: String { rawValue }

        case nopass = "nopass"
        case WEP = "WEP"
        case WPA = "WPA"
        case WPA2_EAP = "WPA2-EAP"

        public var description: String {
            switch self {
            case .nopass: return "No"
            case .WEP: return "WEP"
            case .WPA: return "WPA"
            case .WPA2_EAP: return "WPA2-EAP"
            }
        }
    }

    public var ssid: String
    public var password: String
    public var encryption: Encryption

    public var isWEP: NEHotspotConfiguration {
        NEHotspotConfiguration(
            ssid: ssid,
            passphrase: password,
            isWEP: self.encryption == .WEP
        )
    }
}

public final class WifiParser {
    private let pattern = #"WIFI:S:(?<ssid>.*);T:(?<type>.*);P:(?<password>.*);;"#

    public func parse(_ payload: String) -> WifiData? {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let nsrange = NSRange(
                payload.startIndex..<payload.endIndex,
                in: payload
            )
            var wifiData: WifiData?
            regex.enumerateMatches(
                in: payload,
                options: [],
                range: nsrange
            ) { match, _, stop in
                guard let match = match else { return }

                if match.numberOfRanges == 4,
                   let ssidRange = Range(match.range(at: 1), in: payload),
                   let typeRange = Range(match.range(at: 2), in: payload),
                   let passwordRange = Range(match.range(at: 3), in: payload)
                {
                    let ssid = String(payload[ssidRange])
                    let password = String(payload[passwordRange])
                    let encryptionType = String(payload[typeRange])

                    let encryption = WifiData.Encryption(rawValue: String(encryptionType)) ?? .nopass

                    wifiData = WifiData(
                        ssid: ssid,
                        password: password,
                        encryption: encryption
                    )
                    stop.pointee = true
                }
            }
            return wifiData
        } catch {
            return nil
        }
    }
}
