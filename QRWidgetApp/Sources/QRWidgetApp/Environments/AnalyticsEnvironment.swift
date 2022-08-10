//
//  File.swift
//  
//
//  Created by Максим Казаков on 08.08.2022.
//

import Foundation

public typealias SendAnalyticsAction = (_ event: AnalyticsEvent, _ params: [String: Any]?) -> Void
public typealias SetAnalyticsPropertyAction = (_ key: String, _ value: Any) -> Void

public struct AnalyticsEnvironment {
    public init(sendAnalyticsEvent: @escaping SendAnalyticsAction, setUserProperty: @escaping SetAnalyticsPropertyAction) {
        self.sendAnalyticsEvent = sendAnalyticsEvent
        self.setUserProperty = setUserProperty
    }

    let sendAnalyticsEvent: SendAnalyticsAction
    let setUserProperty: SetAnalyticsPropertyAction

    public static let unimplemented = AnalyticsEnvironment(
        sendAnalyticsEvent: { _, _ in },
        setUserProperty: { _, _ in }
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
