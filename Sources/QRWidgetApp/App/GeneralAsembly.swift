//
//  GeneralAsembly.swift
//  QRWidget
//
//  Created by Максим Казаков on 15.01.2022.
//

import UIKit
import SwiftUI
import QRWidgetCore

var generalAssembly = GeneralAssembly()

class GeneralAssembly {

    lazy var deeplinker = Deeplinker(starter: starter,
                                     qrCodesService: qrCodesService,
                                     sendAnalytics: appEnvironment.analyticsEnvironment.sendAnalyticsEvent)

    // MARK: - Private

    var appEnvironment: AppEnvironment = .unimplemented

    lazy var starter = Starter(
        rootViewController: rootViewController,
        userDefaults: userDefaultsStorage,
        qrCodesRepository: qrCodesRepository,
        qrCodesService: qrCodesService,
        walletService: walletService,
        widgetsService: widgetsService,
        favoritesService: favoritesService,
        oldStorage: oldStorage
    )

    lazy var userDefaultsStorage = UserDefaultsStorage()

    // Services
    lazy var walletService = WalletService(userDefaults: userDefaultsStorage,
                                           walletPassEnvironment: appEnvironment.walletPassEnvironment,
                                           analyticsEnvironment: appEnvironment.analyticsEnvironment)
    lazy var qrCodesService = QRCodesService(repository: qrCodesRepository,
                                             walletService: walletService,
                                             userStorage: userDefaultsStorage,
                                             favotitesService: favoritesService)
    lazy var widgetsService = WidgetsService(repository: qrCodesRepository, favoritesService: favoritesService)
    lazy var favoritesService = FavoritesService()
    lazy var settingsService = SettingsService(storage: userDefaultsStorage)
    lazy var watchPhoneManager = WatchPhoneManager(qrService: qrCodesService)

    // Repositories
    lazy var qrCodesRepository = QRCodesRepository(logMessage: { Logger.debugLog(message: $0) })    
    lazy var oldStorage = Storage()

    lazy var appRouter = AppRouter(rootViewController: rootViewController)

    lazy var rootViewController = RootViewController()

    // Modules

    // Payment
    func makePaywallView(sourceScreen: PaywallSource, shownFromOnboarding: Bool = false, onClose: @escaping () -> Void = {}) -> AnyView {
        PaywallViewFlow(viewModel: PaywallViewModel(source: sourceScreen,
                                                    purchasesEnvironment: self.appEnvironment.paymentEnvironment,
                                                    sendAnalyticsEvent: self.appEnvironment.analyticsEnvironment.sendAnalyticsEvent,
                                                    shownFromOnboarding: shownFromOnboarding,
                                                    onClose: onClose))
        .injectAnalyticsSender(appEnvironment.analyticsEnvironment.sendAnalyticsEvent)
        .anyView
    }

    // Main Tab View
    func makeTabView() -> Module {
        let view = MainTabView(
            viewModel: MainTabViewModel(storage: self.userDefaultsStorage, sendAnalytics: self.appEnvironment.analyticsEnvironment.sendAnalyticsEvent)
        )
            .injectAnalyticsSender(appEnvironment.analyticsEnvironment.sendAnalyticsEvent)
            .anyView
        return Module(router: Router(), view: view)
    }

    // Main Details View
    func makeDetailsViewModule(qrModel: QRModel, options: CodeDetailsPresentaionOptions) -> Module {
        let viewModel = DetailsViewModel(qrModel: qrModel,
                                         qrCodesService: self.qrCodesService,
                                         favoritesService: self.favoritesService,
                                         qrRepository: self.qrCodesRepository,
                                         options: options,
                                         sendAnalytics: appEnvironment.analyticsEnvironment.sendAnalyticsEvent)
        let view = DetailsView(viewModel: viewModel)
            .injectAnalyticsSender(appEnvironment.analyticsEnvironment.sendAnalyticsEvent)
            .anyView
        return Module(router: viewModel.router, view: view)
    }

    func makeDetailsView(qrModel: QRModel) -> some View {
        let viewModel = DetailsViewModel(qrModel: qrModel,
                                         qrCodesService: self.qrCodesService,
                                         favoritesService: self.favoritesService,
                                         qrRepository: self.qrCodesRepository,
                                         options: .zero,
                                         sendAnalytics: appEnvironment.analyticsEnvironment.sendAnalyticsEvent)
        viewModel.router.routerController = generalAssembly.appRouter.rootViewController
        let view = DetailsView(viewModel: viewModel)
        return view
    }

    // Scanner
    func makeQRCodeScannerView() -> some View {
        let scannerViewModel = ScannerViewModel(qrCodeService: qrCodesService,
                                                favoritesService: favoritesService,
                                                settingsService: settingsService,
                                                sendAnalytics: appEnvironment.analyticsEnvironment.sendAnalyticsEvent)
        scannerViewModel.router.routerController = generalAssembly.rootViewController
        let scannerView = ScannerView(viewModel: scannerViewModel)
        return scannerView
    }

    // QR Code pages
    func makeQRCodePagesView() -> some View {
        let qrPagesView = QRPagesView(viewModel: QRPagesViewModel(qrCodesService: self.qrCodesService, storage: self.userDefaultsStorage))
        return qrPagesView
    }

    func makeMultipleCodesRecognized(codes: [QRModel], onClose: @escaping EmptyBlock) -> Module {
        let viewModel = MutlipleQRRecognizedViewModel(favoritesService: favoritesService,
                                                      qrCodesRepository: qrCodesRepository,
                                                      codes: codes,
                                                      onClose: onClose)
        let view = MutlipleQRRecognizedView(viewModel: viewModel)
            .injectAnalyticsSender(appEnvironment.analyticsEnvironment.sendAnalyticsEvent)
        let controller = UIHostingController(rootView: view)
        controller.view.backgroundColor = UIColor.clear
        return Module(router: viewModel.router, controller: controller)
    }

    // Onboarding
    func makeOnboardingModule(onComplete: @escaping EmptyBlock) -> UIViewController {
        let onboardingViewController = OnboardingViewController(
            onComplete: onComplete,
            sendAnalytics: appEnvironment.analyticsEnvironment.sendAnalyticsEvent
        )
        return onboardingViewController
    }

    // Beautify
    func makeBeautifyModule(qrModel: QRModel) -> Module {
        let beautifyViewModel = BeautifyQRViewModel(qrModel: qrModel,
                                                    qrCodesService: qrCodesService,
                                                    sendAnalytics: appEnvironment.analyticsEnvironment.sendAnalyticsEvent)
        let beautifyView = BeautifyQRView(viewModel: beautifyViewModel)
            .injectAnalyticsSender(appEnvironment.analyticsEnvironment.sendAnalyticsEvent)
            .anyView
        return Module(router: beautifyViewModel.router, view: beautifyView)
    }

    // Settings
    func makeSettingsModule() -> some View {
        let viewModel = SettingsViewModel(settingsService: settingsService)
        viewModel.router.routerController = generalAssembly.rootViewController
        let view = SettingsView(viewModel: viewModel).anyView
        return view
    }

    // Add to wallet
    func makeAddToWalletButton(qrModel: QRModel) -> some View {
        AddToWalletButton(
            qrModel: qrModel,
            viewModel: AddToWalletButtonViewModel(walletService: self.walletService,
                                                  sendAnalyticsEvent: self.appEnvironment.analyticsEnvironment.sendAnalyticsEvent)
        )
    }

    // History
    func makeHistoryView() -> some View {
        let hisotryViewModel = HistoryViewModel(qrCodesRepository: self.qrCodesRepository,
                                                favoritesService: self.favoritesService)
        let historyView = HistoryView(viewModel: hisotryViewModel)
        return historyView
    }

    // History
    func makeBatchCodesView(batchId: UUID) -> some View {
        let hisotryViewModel = BatchCodesViewModel(batchId: batchId,
                                                   qrCodesRepository: qrCodesRepository,
                                                   favoritesService: favoritesService)
        let historyView = HistoryView(viewModel: hisotryViewModel)
        return historyView
    }

    // Main Details View
    func makeShareView(parentRouter: Router, qrModel: QRModel, source: AnalyticsSource.Share, customButton: (() -> AnyView)? = nil) -> some View {
        let viewModel = ShareMenuViewModel(source: source, sendAnalytics: appEnvironment.analyticsEnvironment.sendAnalyticsEvent)
        viewModel.router = parentRouter
        let view = ShareMenuView(qrModel: qrModel, customButton: customButton, viewModel: viewModel)
        return view
    }

    func makeSingleQRRowView(model: SingleCodeRowUIModel) -> some View {
        SingleCodeRowView(model: model,
                          viewModel: SingleCodeRowViewModel(id: model.id, favoritesService: self.favoritesService))
    }
}

private extension View {
    func injectAnalyticsSender(_ sender: @escaping SendAnalyticsAction) -> some View {
        self
            .environment(\.sendAnalyticsEvent, sender)
    }
}
