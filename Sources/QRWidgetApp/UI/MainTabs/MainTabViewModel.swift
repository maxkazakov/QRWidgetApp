
import SwiftUI
import Foundation
import Combine
import StoreKit

class MainTabViewModel: ViewModel {

    let qrCodeService: QRCodesService
    let codesService: CodesService

    let storage: UserDefaultsStorage
    let sendAnalytics: SendAnalyticsAction
    @Published var currentTab: Tab = .scan
    @Published var presentingPaywall = false

    lazy var allCodesTabModel: AllCodesViewModel = {
        let model = AllCodesViewModel(
            codesService: self.qrCodeService,
            sendAnalytics: self.sendAnalytics
        )
        model.startScanningTapped = { [weak self] in
            self?.currentTab = .scan
        }
        model.createQRTapped = { [weak self] in
            self?.sendAnalytics(.tapCreateNewQR, [:])
            self?.currentTab = .create
        }
        return model
    }()

    lazy var codeCreationModel: CodeCreationFlowModel = {
        let model = CodeCreationFlowModel()
        return model
    }()

    init(
        qrCodeService: QRCodesService,
        codesService: CodesService,
        storage: UserDefaultsStorage,
        sendAnalytics: @escaping SendAnalyticsAction
    ) {
        self.qrCodeService = qrCodeService
        self.codesService = codesService
        self.storage = storage
        self.sendAnalytics = sendAnalytics
        super.init()

        initializeSelectedTab()
        $currentTab
            .removeDuplicates()
            .sink(receiveValue: { [weak self] in
                self?.trackTabChange(tab: $0)
                self?.storage.selectedTab = $0.rawValue
            })
            .store(in: &cancellableSet)
    }

    var wasAppeared = false

    func onAppear() {
        guard !wasAppeared else { return }
        wasAppeared = true
        let codesCount = generalAssembly.qrCodesService.qrCodesPublisher.value.count
        tryAskForReviewOrShowPaywall(codesCount: codesCount)
    }

    // MARK: - Private

    private func tryAskForReviewOrShowPaywall(codesCount: Int) {
        guard codesCount > 0 else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            if self.isProActivated {
                self.askReview()
            } else {
                let randomValue = Int.random(in: 0...1)
                print("tryAskForReviewOrShowPaywall, random value is", randomValue)
                if randomValue == 0 {
                    self.presentingPaywall = true
                } else {
                    self.askReview()
                }
            }
        }
    }

    private func askReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    private func trackTabChange(tab: Tab) {
        switch tab {
        case .scan:
            sendAnalytics(.openScanTab, nil)
        case .history:
            sendAnalytics(.openHistoryTab, nil)
        case .settings:
            sendAnalytics(.openSettingsTab, nil)
        case .create:
            sendAnalytics(.openCreateTab, nil)
        }
    }

    private func initializeSelectedTab() {
        if let storedSelectedTab = storage.selectedTab.flatMap({ Tab(rawValue: $0) }) {
            currentTab = storedSelectedTab
        } else {
            currentTab = .scan
        }
    }
}

