//
//  Starter.swift
//  QRWidget
//
//  Created by Максим Казаков on 15.01.2022.
//

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
    private let oldStorage: Storage

    private var cancellableSet = Set<AnyCancellable>()
    var isAppStartedPublisher = CurrentValueSubject<Bool, Never>(false)

    init(rootViewController: RootViewController,
         userDefaults: UserDefaultsStorage,
         qrCodesRepository: QRCodesRepository,
         qrCodesService: QRCodesService,
         walletService: WalletService,
         widgetsService: WidgetsService,
         favoritesService: FavoritesService,
         oldStorage: Storage
    ) {
        self.rootViewController = rootViewController
        self.userDefaultsStorage = userDefaults
        self.qrCodesService = qrCodesService
        self.qrCodesRepository = qrCodesRepository
        self.walletService = walletService
        self.oldStorage = oldStorage
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

        Publishers.CombineLatest(
            initializeRepositories(),
            generalAssembly.appEnvironment.paymentEnvironment.getProVersionActivated()
        )
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { (_, isActivated) in
                self.onAppReady()
            })
            .store(in: &cancellableSet)
    }

    private func onAppReady() {
        walletService.loadAndValidatePasses()
        widgetsService.subscribeQrChanges()

        setupTabbar()
        setupAnalyticsUserOptions()
        startWatchSession()

        var needToShowOnboarding = !userDefaultsStorage.onboardingWasShown
            && !generalAssembly.appEnvironment.paymentEnvironment.isProActivated()
        #if DEBUG
        needToShowOnboarding = true
        #endif

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

        #if !DEBUG
        tryAskForReview(qrCount: qrCodesRepository.qrCodes.count)
        #endif

        Logger.debugLog(message: "App Starter: End")
        isAppStartedPublisher.send(true)
    }

    private func showTabsController() {
        let qrPagesModule = generalAssembly.makeTabView()
        rootViewController.set(viewController: qrPagesModule.controller)
    }

    private func setupTabbar() {
        if let storedSelectedTab = userDefaultsStorage.selectedTab.flatMap({ Tab(rawValue: $0) }) {
            selectedTabBarPublisher.send(storedSelectedTab)
        } else {
            if qrCodesRepository.qrCodes.count == 0 {
                selectedTabBarPublisher.send(.scan)
            } else {
                selectedTabBarPublisher.send(.favorites)
            }
        }
    }

    private func setupAnalyticsUserOptions() {
        let qrCount = qrCodesRepository.qrCodes.count
        let openCounter = userDefaultsStorage.openAppCounter
        generalAssembly.appEnvironment.analyticsEnvironment.setUserOptions(qrCount: qrCount, openAppCounter: openCounter)
    }

    private func initializeRepositories() -> AnyPublisher<Void, Never> {
        qrCodesRepository.loadAllQrFromStoragePublisher()
            .flatMap {
                self.mirgateDataToRepositories()
            }
            .eraseToAnyPublisher()
    }

    private func startWatchSession() {
        generalAssembly.watchPhoneManager.startSession()
    }

    // MARK: - Migrations

    private func mirgateDataToRepositories() -> AnyPublisher<Void, Never> {
        oldStorage.loadStatePublisher()
            .flatMap { stateOptional -> AnyPublisher<Void, Never> in
                if let state = stateOptional {
                    self.mirgateFromStateToUserDefaultsIfNeeded(state: state)
                    self.mirgateFromRedux(state: state)
                }
                self.mirgateFavotites()
                return Just(()).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func mirgateFavotites() {
        if userDefaultsStorage.hasValue(for: UserDefaultsKey.favoritesIdsKey) {
            return
        }
        let allIds = qrCodesRepository.qrCodes.map { $0.id }
        favoritesService.setFavotites(ids: Set(allIds))
    }

    private func mirgateFromStateToUserDefaultsIfNeeded(state: AppStateDto) {
        if userDefaultsStorage.hasValue(for: UserDefaultsKey.onboardingWasShown) {
            return
        }
        userDefaultsStorage.onboardingWasShown = state.data.onboardingWasShown ?? false
    }

    private func mirgateFromRedux(state: AppStateDto) {
        if userDefaultsStorage.mirgatedFromRedux {
            return
        }
        Logger.debugLog(message: "Mirgation from redux. Start")
        // Move QR-s
        for qrCodeDto in state.data.allQRs {
            let qrCodeModel = qrCodeDto.makeModel()
            qrCodesRepository.addNew(qr: qrCodeModel)
        }
        // Move Passes
        for (qrId, passId) in state.data.allWalletPasses {
            walletService.addPass(qrId: qrId, passId: passId)
        }
        // Move selected
        if let selectedQr = state.data.selectedQR {
            userDefaultsStorage.selectedQR = selectedQr
        }
        Logger.debugLog(message: "Mirgation from redux. Finish. Mirgated \(state.data.allQRs.count) qrCodes, \(state.data.allWalletPasses) wallet passes, selectedQrId: \(String(describing: state.data.selectedQR))")
        // Finish migrations
        userDefaultsStorage.mirgatedFromRedux = true
    }

    private func tryAskForReview(qrCount: Int) {
        guard qrCount > 0 else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
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
    }
}
