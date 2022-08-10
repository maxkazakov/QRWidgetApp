//
//  AppEnvironment.swift
//  QRWidget
//
//  Created by Максим Казаков on 02.08.2022.
//

import Foundation
import Combine
import SwiftUI
import StoreKit

public typealias LoggingAction = (_ message: String) -> Void

public struct AppEnvironment {
    public init(analyticsEnvironment: AnalyticsEnvironment,
                paymentEnvironment: PurchasesEnvironment,
                walletPassEnvironment: WalletPassEnvironment,
                debugLog: @escaping LoggingAction) {
        self.analyticsEnvironment = analyticsEnvironment
        self.paymentEnvironment = paymentEnvironment
        self.walletPassEnvironment = walletPassEnvironment
        self.debugLog = debugLog
    }

    let analyticsEnvironment: AnalyticsEnvironment
    let paymentEnvironment: PurchasesEnvironment
    let walletPassEnvironment: WalletPassEnvironment
    let debugLog: LoggingAction

    public static let unimplemented = AppEnvironment(
        analyticsEnvironment: .unimplemented,
        paymentEnvironment: .unimplemented,
        walletPassEnvironment: .unimplemented,
        debugLog: { _ in }
    )
}
