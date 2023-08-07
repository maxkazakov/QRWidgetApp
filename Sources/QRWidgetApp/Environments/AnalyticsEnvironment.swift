
import Foundation
import Dependencies
import XCTestDynamicOverlay

public typealias SendAnalyticsAction = (_ event: AnalyticsEvent, _ params: [String: Any]?) -> Void
public typealias SetAnalyticsPropertyAction = (_ key: String, _ value: Any) -> Void

extension DependencyValues {
    var analytics: AnalyticsEnvironment {
        get { self[AnalyticsKey.self] }
        set { self[AnalyticsKey.self] = newValue }
    }
}

enum AnalyticsKey: DependencyKey {
    public static var liveValue: AnalyticsEnvironment {
        .live
    }
}

public extension AnalyticsEnvironment {
    static var live: AnalyticsEnvironment = .unimplemented
}

public struct AnalyticsEnvironment {
    public init(sendAnalyticsEvent: @escaping SendAnalyticsAction, setUserProperty: @escaping SetAnalyticsPropertyAction) {
        self.sendAnalyticsEvent = sendAnalyticsEvent
        self.setUserProperty = setUserProperty
    }

    var sendAnalyticsEvent: SendAnalyticsAction
    var setUserProperty: SetAnalyticsPropertyAction

    public static let unimplemented = AnalyticsEnvironment(
        sendAnalyticsEvent: { _, _ in XCTestDynamicOverlay.unimplemented("sendAnalyticsEvent is not implemented") },
        setUserProperty: { _, _ in XCTestDynamicOverlay.unimplemented("setUserProperty is not implemented") }
    )
}

extension AnalyticsEnvironment {
    func setUserOptions(qrCount: Int, openAppCounter: Int) {
        setUserProperty(UserProps.qrCodesCountKey, qrCount)
        setUserProperty(UserProps.openAppCountKey, openAppCounter)
    }

    func updateWalletPassCount(passCount: Int) {
        setUserProperty(UserProps.walletPassesCountKey, passCount)
    }
}

enum UserProps {
    static let qrCodesCountKey = "qrCodesCount"
    static let openAppCountKey = "openAppCount"
    static let walletPassesCountKey = "walletPassesCount"
}
