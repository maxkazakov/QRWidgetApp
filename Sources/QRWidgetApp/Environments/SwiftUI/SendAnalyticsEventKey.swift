//
//  SendAnalyticsEventKey.swift
//  
//
//  Created by Максим Казаков on 09.08.2022.
//

import Foundation
import SwiftUI

private struct SendAnalyticsEventKey: EnvironmentKey {
    static let defaultValue: SendAnalyticsAction = { _, _ in fatalError() }
}

extension EnvironmentValues {
    var sendAnalyticsEvent: SendAnalyticsAction {
        get { self[SendAnalyticsEventKey.self] }
        set { self[SendAnalyticsEventKey.self] = newValue }
    }
}

