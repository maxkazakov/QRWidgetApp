//
//  StorableAppState.swift
//  QRWidget
//
//  Created by Максим Казаков on 17.10.2021.
//

import Foundation

public struct AppStateDto: Codable {
    var version: Int = currentVersion
    let data: AppStateData_V2
}

extension AppStateDto {
    static let currentVersion = 2
}

struct AppStateData_V2: Codable {
    let selectedQR: UUID?
    let allQRs: [QRModelDto]
    let allWalletPasses: [UUID: String]

    let isSubscriptionActivated: Bool
    let onboardingWasShown: Bool?
}

