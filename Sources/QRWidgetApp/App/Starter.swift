import UIKit
import SwiftUI
import Combine
import StoreKit
#if !os(watchOS)
import WidgetKit
import Lottie
#endif

public class Starter {
    private let rootViewController: RootViewController!
    private let userDefaultsStorage: UserDefaultsStorage
    private let qrCodesRepository: QRCodesRepository
    private let qrCodesService: QRCodesService
    private let walletService: WalletService
    private let widgetsService: WidgetsService
    private let favoritesService: FavoritesService

    private var cancellableSet = Set<AnyCancellable>()
    var isAppStartedPublisher = CurrentValueSubject<Bool, Never>(false)

    init(rootViewController: RootViewController,
         userDefaults: UserDefaultsStorage,
         qrCodesRepository: QRCodesRepository,
         qrCodesService: QRCodesService,
         walletService: WalletService,
         widgetsService: WidgetsService,
         favoritesService: FavoritesService
    ) {
        self.rootViewController = rootViewController
        self.userDefaultsStorage = userDefaults
        self.qrCodesService = qrCodesService
        self.qrCodesRepository = qrCodesRepository
        self.walletService = walletService
        self.widgetsService = widgetsService
        self.favoritesService = favoritesService
    }

    public func start(window: UIWindow) {
        Logger.debugLog(message: "App Starter: Begin")

        userDefaultsStorage.openAppCounter += 1

        setupWidgets()
        setupAppearance()
        window.rootViewController = rootViewController
        let bootstrapViewContoller = UIHostingController(rootView: BootstrapView())
        rootViewController.set(viewController: bootstrapViewContoller)
        window.makeKeyAndVisible()

        let codes = qrCodesRepository.loadAllCodes()
        let codesCount = codes.count

        walletService.loadAndValidatePasses()
        widgetsService.subscribeQrChanges()

        setupAnalyticsUserOptions(codesCount: codesCount)
        startWatchSession()

        var needToShowOnboarding = !userDefaultsStorage.onboardingWasShown
            && !generalAssembly.appEnvironment.paymentEnvironment.isProActivated()
        //        #if DEBUG
        //        needToShowOnboarding = true
        //        #endif

        if needToShowOnboarding {
            let onboardingCompletion = {
                self.userDefaultsStorage.onboardingWasShown = true
                self.rootViewController.dismiss(animated: true, completion: nil)
                self.showTabsController()
            }
            generalAssembly.appRouter.route(route: .onboarding(onComplete: onboardingCompletion))
        } else {
            showTabsController()
        }

        // #if !DEBUG
        tryAskForReview(codesCount: codesCount)
        // #endif

        Logger.debugLog(message: "App Starter: End")
        isAppStartedPublisher.send(true)
    }

    private func showTabsController() {
        let qrPagesModule = generalAssembly.makeTabView()
        rootViewController.set(viewController: qrPagesModule.controller)
    }

    private func setupAnalyticsUserOptions(codesCount: Int) {
        let openCounter = userDefaultsStorage.openAppCounter
        generalAssembly.appEnvironment.analyticsEnvironment.setUserOptions(qrCount: codesCount, openAppCounter: openCounter)
    }

    private func startWatchSession() {
        generalAssembly.watchPhoneManager.startSession()
    }

    // MARK: - Migrations

    private func tryAskForReview(codesCount: Int) {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    func setupWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }

    func setupAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = Asset.primaryColor.color
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
        UIScrollView.appearance().keyboardDismissMode = .onDrag

        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()

        let transprentAppearance = UINavigationBarAppearance()
        transprentAppearance.configureWithTransparentBackground()

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = transprentAppearance

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithDefaultBackground()

        UITabBar.appearance().standardAppearance = tabAppearance

        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }
    }
}
