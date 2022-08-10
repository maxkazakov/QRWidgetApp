//
//  PaywallViewModel.swift
//  QRWidget
//
//  Created by Максим Казаков on 26.10.2021.
//

import SwiftUI
import Combine
import StoreKit

public enum QRProductType: String {
    case oneTime
    case subscription
}

public struct QRProduct: Equatable {
    public init(id: String, skProduct: SKProduct, isPopular: Bool, title: String, priceInfo: String, type: QRProductType, purchase: @escaping () -> AnyPublisher<Void, PurchasesError>) {
        self.id = id
        self.skProduct = skProduct
        self.isPopular = isPopular
        self.title = title
        self.priceInfo = priceInfo
        self.type = type
        self.purchase = purchase
    }

    let id: String
    let skProduct: SKProduct
    let isPopular: Bool
    let title: String
    let priceInfo: String
    let type: QRProductType
    let purchase: () -> AnyPublisher<Void, PurchasesError>

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

public enum PurchasesError: Error {
    case unknown
    case noAvailablePackages
    case cancelled
    case custom(String)
}

class PaywallViewModel: ViewModel {

    let source: PaywallSource
    let onClose: (() -> Void)?
    let sendAnalyticsEvent: SendAnalyticsAction

    var shownFromOnboarding: Bool = false
    var products: [QRProduct] = []
    let purchasesEnvironment: PurchasesEnvironment

    @Published var needToClose = false
    @Published var closeButtonIsHidden: Bool = false
    @Published var state: State = .loading
    @Published var selectedProductIdx: Int = 0
    
    enum State: Equatable {
        case succeed
        case error(String)
        case loading
        case data
    }
    
    init(source: PaywallSource,
         purchasesEnvironment: PurchasesEnvironment,
         sendAnalyticsEvent: @escaping SendAnalyticsAction,
         shownFromOnboarding: Bool = false,
         state: State = .loading,
         products: [QRProduct] = [],
         onClose: (() -> Void)? = nil) {
        self.state = state
        self.products = products
        self.source = source
        self.shownFromOnboarding = shownFromOnboarding
        self.closeButtonIsHidden = shownFromOnboarding
        self.onClose = onClose
        self.sendAnalyticsEvent = sendAnalyticsEvent
        self.purchasesEnvironment = purchasesEnvironment
    }

    var isAlreadyAppeared = false
    func onAppear() {
        guard !isAlreadyAppeared else { return }
        isAlreadyAppeared = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.start()
        }
    }

    override func close() {
        if shownFromOnboarding {
            sendAnalyticsEvent(.tapCloseOnPaywallOnboarding, nil)
        } else {
            sendAnalyticsEvent(.closePaywall, ["source": NSString(string: self.source.rawValue)])
        }
        onClose?()
        needToClose = true
    }

    
    var selectedProduct: QRProduct {
        products[selectedProductIdx]
    }
    
    func select(_ product: QRProduct) {
        selectedProductIdx = products.firstIndex (where: { $0 == product })!
        sendAnalyticsEvent(.tapOnProduct, [
            "source": NSString(string: source.rawValue),
            "productType": NSString(string: product.type.rawValue)
        ])
    }
    
    func activate() {
        sendAnalyticsEvent(.tapActivate, ["source": NSString(string: source.rawValue)])
        state = .loading

        let eventParams: [String: AnyObject] = [
            "source": NSString(string: source.rawValue),
            "productId": NSString(string: selectedProduct.id),
            "productType": NSString(string: selectedProduct.type.rawValue)
        ]

        let type = selectedProduct.type
        selectedProduct.purchase()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] in
                if case let .failure(error) = $0 {
                    switch error {
                    case .cancelled:
                        self?.sendAnalyticsEvent(.tapCancelOnPaymentAlert, eventParams)
                        self?.state = .data
                    default:
                        self?.state = .error(error.localizedDescription)
                    }
                }
            }, receiveValue: { [weak self] _ in
                self?.state = .succeed
                switch type {
                case .oneTime:
                    self?.sendAnalyticsEvent(.activatedOnetimePurchase, eventParams)
                case .subscription:
                    self?.sendAnalyticsEvent(.activatedSubscription, eventParams)
                }
            })
            .store(in: &cancellableSet)
    }
    
    func restore() {
        sendAnalyticsEvent(.tapRestorePurchase, nil)
        state = .loading

        purchasesEnvironment.restore()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] in
                if case let .failure(error) = $0 {
                    let errorString = error.localizedDescription
                    self?.sendAnalyticsEvent(.paywallErrorScreenOpened, nil)
                    self?.state = .error(errorString)
                }
            },
                  receiveValue: { [weak self] in
                self?.state = .succeed
            })
            .store(in: &cancellableSet)
    }
    
    func start() {
        if shownFromOnboarding {
            startTimerForCloseButton()
        }
        sendAnalyticsEvent(.paywallActivateScreenOpened, ["source": NSString(string: self.source.rawValue)])
        self.state = .loading

        purchasesEnvironment.offerings()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] in
                if case let .failure(error) = $0 {
                    let errorString = error.localizedDescription
                    self?.sendAnalyticsEvent(.paywallErrorScreenOpened, nil)
                    self?.state = .error(errorString)
                }
            }, receiveValue: { [weak self] products in
                self?.state = .data
                self?.products = products
            })
            .store(in: &cancellableSet)
    }

    func startTimerForCloseButton() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
            self.closeButtonIsHidden = false
        })
    }
}
