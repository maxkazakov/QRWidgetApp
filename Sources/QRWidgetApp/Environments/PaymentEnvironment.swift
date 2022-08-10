//
//  File.swift
//  
//
//  Created by Максим Казаков on 08.08.2022.
//

import Foundation
import Combine
import StoreKit

public enum PaywallSource: String {
    case onboarding
    case changeAppearance
    case batchScan
    case details
    case addSecondQrCore
    case appleWallet
    case settings
    case scan
}

public struct PurchasesEnvironment {
    public init(getProVersionActivated: @escaping () -> AnyPublisher<Bool, Never>,
                proActivatedPublisher: @escaping () -> AnyPublisher<Bool, Never>,
                isProActivated: @escaping () -> Bool,
                purchase: @escaping (_ product: SKProduct) -> AnyPublisher<Void, PurchasesError>,
                offerings: @escaping () -> AnyPublisher<[QRProduct], Error>,
                restore: @escaping () -> AnyPublisher<Void, Error>
    ) {
        self.getProVersionActivated = getProVersionActivated
        self.proActivatedPublisher = proActivatedPublisher
        self.isProActivated = isProActivated
        self.purchase = purchase
        self.offerings = offerings
        self.restore = restore
    }

    public var getProVersionActivated: () -> AnyPublisher<Bool, Never>
    public var proActivatedPublisher: () -> AnyPublisher<Bool, Never>
    public var isProActivated: () -> Bool

    public var purchase: (_ product: SKProduct) -> AnyPublisher<Void, PurchasesError>
    public var offerings: () -> AnyPublisher<[QRProduct], Error>
    public var restore: () -> AnyPublisher<Void, Error>
}

public extension PurchasesEnvironment {
    static let unimplemented = PurchasesEnvironment(
        getProVersionActivated: { Just(true).eraseToAnyPublisher() },
        proActivatedPublisher: { Just(true).eraseToAnyPublisher() },
        isProActivated: { true },
        purchase: { _ in fatalError("purchase not implemented") },
        offerings: { Just([]).setFailureType(to: Error.self).eraseToAnyPublisher() },
        restore: { fatalError("restore not implemented") }
    )
}
