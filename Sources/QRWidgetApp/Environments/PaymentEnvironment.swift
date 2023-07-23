

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
    case randomlyOnStart
}

public struct PurchasesEnvironment {
    public init(getProVersionActivated: @escaping () -> AnyPublisher<Bool, Never>,
                proActivatedPublisher: @escaping () -> AnyPublisher<Bool, Never>,
                isProActivated: @escaping () -> Bool,
                offerings: @escaping () -> AnyPublisher<[QRProduct], Error>,
                restore: @escaping () -> AnyPublisher<Void, Error>
    ) {
        self.getProVersionActivated = getProVersionActivated
        self.proActivatedPublisher = proActivatedPublisher
        self.isProActivated = isProActivated
        self.offerings = offerings
        self.restore = restore
    }

    public var getProVersionActivated: () -> AnyPublisher<Bool, Never>
    public var proActivatedPublisher: () -> AnyPublisher<Bool, Never>
    public var isProActivated: () -> Bool

    public var offerings: () -> AnyPublisher<[QRProduct], Error>
    public var restore: () -> AnyPublisher<Void, Error>
}

public extension PurchasesEnvironment {
    static let unimplemented = PurchasesEnvironment(
        getProVersionActivated: { Just(true).eraseToAnyPublisher() },
        proActivatedPublisher: { Just(true).eraseToAnyPublisher() },
        isProActivated: { true },
        offerings: {
            let products = [QRProduct(id: "1", isPopular: true, title: "Forever", priceInfo: "$15", type: .oneTime, purchase: {
                Fail(error: PurchasesError.custom("Purchasing is not implemented")).eraseToAnyPublisher()
            })]
            return Just(products).setFailureType(to: Error.self).eraseToAnyPublisher()
        },
        restore: {
            Fail(error: PurchasesError.custom("Restoring is not implemented")).eraseToAnyPublisher()
        }
    )
}
