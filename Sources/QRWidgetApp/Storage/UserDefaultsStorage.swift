
import Foundation
import QRWidgetCore

let appGroupID = "group.ru.maxkazakov.QRWidget"

enum UserDefaultsKey {

    // I screwed it up with raw value. It's used only for widgets, so fuck this
    static let isProVersionActivated = "hasActiveWidgets"

    static let onboardingWasShown = "onboardingWasShown"
    static let isFlipTipWasShown = "isFlipTipWasShown"

    static let openAppCounter = "openAppCounter"
    static let walletPassesByQRCodeIdKey = "walletPassesByQRCodeId"

    static let favoritesIdsKey = "favoritesIds"
    static let selectedTabKey = "selectedTab"

    static let vibrationOnCodeRecognized = "vibrationOnCodeRecognized"
    static let batchScanHintWasShown = "batchUpdateHintWasShown"
}

public class UserDefaultsStorage {

    private let groupUserDefaults = UserDefaults(suiteName: appGroupID)!

    public init() {
        groupUserDefaults.register(
            defaults: [
                UserDefaultsKey.vibrationOnCodeRecognized : 1
            ]
        )
    }

    public var isProVersionActivated: Bool {
        get { getInt(key: UserDefaultsKey.isProVersionActivated) == 1 }
        set { setInt(newValue ? 1 : 0, key: UserDefaultsKey.isProVersionActivated) }
    }

    public var isFlipTipWasShown: Bool {
        get { getInt(key: UserDefaultsKey.isFlipTipWasShown) == 1 }
        set { setInt(newValue ? 1 : 0, key: UserDefaultsKey.isFlipTipWasShown) }
    }

    public var onboardingWasShown: Bool {
        get { getInt(key: UserDefaultsKey.onboardingWasShown) == 1 }
        set { setInt(newValue ? 1 : 0, key: UserDefaultsKey.onboardingWasShown) }
    }

    public var openAppCounter: Int {
        get { getInt(key: UserDefaultsKey.openAppCounter) }
        set { setInt(newValue, key: UserDefaultsKey.openAppCounter) }
    }

    public var walletPassesByQRCodeId: [UUID: String] {
        get {
            guard let dict = getDict(key: UserDefaultsKey.walletPassesByQRCodeIdKey) else {
                return [:]
            }
            let readyForStorageDict = dict.reduce([UUID: String](), { acc, tuple in
                var result = acc
                if let qrId = UUID(uuidString: tuple.key), let passId = tuple.value as? String {
                    result[qrId] = passId
                }
                return result
            })
            return readyForStorageDict
        }
        set {
            let readyForStorageDict = newValue.reduce([String: Any](), { acc, tuple in
                var result = acc
                result[tuple.key.uuidString] = tuple.value
                return result
            })
            setDict(readyForStorageDict, key: UserDefaultsKey.walletPassesByQRCodeIdKey)
        }
    }

    public var favoriteIds: [UUID] {
        get {
            getArray(key: UserDefaultsKey.favoritesIdsKey)?
                .compactMap { $0 as? String }
                .compactMap { UUID(uuidString: $0) } ?? []
        }
        set { setArray(newValue.map { $0.uuidString }, key: UserDefaultsKey.favoritesIdsKey) }
    }

    var selectedTab: Int? {
        get {
            getInt(key: UserDefaultsKey.selectedTabKey)
        }
        set {
            newValue.map { setInt($0, key: UserDefaultsKey.selectedTabKey) }

        }
    }

    var vibrationOnCodeRecognized: Bool {
        get { getInt(key: UserDefaultsKey.vibrationOnCodeRecognized) == 1 }
        set { setInt(newValue ? 1 : 0, key: UserDefaultsKey.vibrationOnCodeRecognized) }
    }

    var batchScanHintWasShown: Bool {
        get { getBool(key: UserDefaultsKey.batchScanHintWasShown) }
        set { setBool(newValue, key: UserDefaultsKey.batchScanHintWasShown) }
    }

    // MARK: -Private
    func hasValue(for key: String) -> Bool {
        groupUserDefaults.object(forKey: key) != nil
    }

    private func getString(key: String) -> String? {
        groupUserDefaults.string(forKey: key)
    }

    private func setString(_ value: String?, key: String) {
        groupUserDefaults.set(value, forKey: key)
    }

    private func getInt(key: String) -> Int {
        groupUserDefaults.integer(forKey: key)
    }

    private func setInt(_ value: Int, key: String) {
        groupUserDefaults.set(value, forKey: key)
    }

    private func getBool(key: String) -> Bool {
        groupUserDefaults.bool(forKey: key)
    }

    private func setBool(_ value: Bool, key: String) {
        groupUserDefaults.set(value, forKey: key)
    }

    private func getDict(key: String) -> [String: Any]? {
        groupUserDefaults.dictionary(forKey: key)
    }

    private func setDict(_ value: [String: Any], key: String) {
        groupUserDefaults.set(value, forKey: key)
    }

    private func getArray(key: String) -> [Any]? {
        groupUserDefaults.array(forKey: key)
    }

    private func setArray(_ value: [String], key: String) {
        groupUserDefaults.set(value, forKey: key)
    }
}
