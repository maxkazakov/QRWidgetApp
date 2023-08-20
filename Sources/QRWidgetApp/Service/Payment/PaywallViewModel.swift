
import SwiftUI
import Combine
import StoreKit
import SwiftUINavigation

public enum QRProductType: String {
    case oneTime
    case subscription
}

public struct QRProduct: Equatable {
    public init(id: String, isPopular: Bool, title: String, priceInfo: String, type: QRProductType, purchase: @escaping () -> AnyPublisher<Void, PurchasesError>) {
        self.id = id
        self.isPopular = isPopular
        self.title = title
        self.priceInfo = priceInfo
        self.type = type
        self.purchase = purchase
    }

    let id: String
    let isPopular: Bool
    let title: String
    let priceInfo: String
    let type: QRProductType
    let purchase: () -> AnyPublisher<Void, PurchasesError>

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

public enum PurchasesError: LocalizedError {
    case unknown
    case noAvailablePackages
    case cancelled
    case custom(String)

    public var errorDescription: String? {
        switch self {
        case .unknown: return "Unknown error"
        case .noAvailablePackages: return "No available packages"
        case .cancelled: return ""
        case let .custom(errorMessage): return errorMessage
        }
    }
}

class PaywallViewModel: ViewModel {

    let source: PaywallSource
    let onClose: (() -> Void)?
    let sendAnalyticsEvent: SendAnalyticsAction

    var shownFromOnboarding: Bool = false
    let purchasesEnvironment: PurchasesEnvironment

    @Published var products: [QRProduct] = []
    @Published var needToClose = false
    @Published var closeButtonIsHidden: Bool = false
    @Published var isLoading = false
    @Published var alert: Alert?
    @Published var selectedProductIdx: Int = 0
    
    enum Alert: Equatable {
        case error(AlertState<ErrorAlertAction>)
    }

    enum ErrorAlertAction: Equatable {
        case tapDismiss
    }
    
    init(
        source: PaywallSource,
        purchasesEnvironment: PurchasesEnvironment,
        sendAnalyticsEvent: @escaping SendAnalyticsAction,
        shownFromOnboarding: Bool = false,
        products: [QRProduct] = [],
        onClose: (() -> Void)? = nil
    ) {
        self.products = products
        self.source = source
        self.shownFromOnboarding = shownFromOnboarding
        self.closeButtonIsHidden = shownFromOnboarding
        self.onClose = onClose
        self.sendAnalyticsEvent = sendAnalyticsEvent
        self.purchasesEnvironment = purchasesEnvironment
        super.init()

        self.loadProducts()
    }

    func tapOkOnAlert() {
        print("tapOkOnAlert called")
        self.alert = nil
    }

    func tapCloseButton() {
        if shownFromOnboarding {
            sendAnalyticsEvent(.tapCloseOnPaywallOnboarding, nil)
        } else {
            sendAnalyticsEvent(.closePaywall, ["source": NSString(string: self.source.rawValue)])
        }
        closePaywall()
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
        guard !products.isEmpty else {
            return
        }
        sendAnalyticsEvent(.tapActivate, ["source": NSString(string: source.rawValue)])
        isLoading = true

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
                    default:
                        self?.showError(message: error.localizedDescription)
                    }
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] _ in
                self?.isLoading = false
                switch type {
                case .oneTime:
                    self?.sendAnalyticsEvent(.activatedOnetimePurchase, eventParams)
                case .subscription:
                    self?.sendAnalyticsEvent(.activatedSubscription, eventParams)
                }
                self?.onPurchaseSuccess()
            })
            .store(in: &cancellableSet)
    }
    
    func restore() {
        sendAnalyticsEvent(.tapRestorePurchase, nil)
        isLoading = true

        purchasesEnvironment.restore()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] in
                if case let .failure(error) = $0 {
                    let errorString = error.localizedDescription
                    self?.sendAnalyticsEvent(.paywallErrorScreenOpened, nil)
                    self?.isLoading = false
                    self?.showError(message: errorString)
                }
            },
                  receiveValue: { [weak self] in
                self?.isLoading = false
                self?.onPurchaseSuccess()
            })
            .store(in: &cancellableSet)
    }

    // MARK: - Private

    private func showError(message: String) {
        let alertState = AlertState<ErrorAlertAction>(
            title: TextState("Something went wrong"),
            message: TextState(message),
            dismissButton: ButtonState(action: .send(.tapDismiss), label: { TextState("Ok") })
        )
        alert = .error(alertState)
    }

    private func loadProducts() {
        if shownFromOnboarding {
            startTimerForCloseButton()
        }
        sendAnalyticsEvent(.paywallActivateScreenOpened, ["source": NSString(string: self.source.rawValue)])

        purchasesEnvironment.offerings()
            .retry(10)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] in
                if case let .failure(error) = $0 {
                    let errorString = error.localizedDescription
                    self?.sendAnalyticsEvent(.paywallErrorScreenOpened, ["error": errorString])
                }
            }, receiveValue: { [weak self] products in
                self?.products = products
            })
            .store(in: &cancellableSet)
    }

    private func startTimerForCloseButton() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
            self.closeButtonIsHidden = false
        })
    }

    private func onPurchaseSuccess() {
        closePaywall()
    }

    private func closePaywall() {
        onClose?()
        needToClose = true
    }
}
