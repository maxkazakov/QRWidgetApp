import SwiftUI
import XCTestDynamicOverlay

enum SelectedTab: Int {
    case favorites = 0
    case scans = 1
    case my = 2
}

class AllCodesViewModel: ObservableObject {

    init(codesService: QRCodesService, sendAnalytics: @escaping SendAnalyticsAction) {
        self.codesService = codesService
        self.sendAnalytics = sendAnalytics
    }

    @Published var selectedTab: SelectedTab = .scans

    var startScanningTapped: EmptyBlock = unimplemented("AllCodesViewModel.startScanningTapped") {
        didSet {
            historyViewModel.startScanningTapped = startScanningTapped
        }
    }

    var createQRTapped: EmptyBlock = unimplemented("AllCodesViewModel.createQRTapped") {
        didSet {
            myCodesViewModel.createNewTapped = createQRTapped
        }
    }

    private let codesService: QRCodesService
    private let sendAnalytics: SendAnalyticsAction

    lazy var historyViewModel: HistoryViewModel = {
        HistoryViewModel(qrCodesService: codesService, favoritesService: generalAssembly.favoritesService)
    }()

    lazy var favoritesViewModel: FavoritesViewModel = {
        FavoritesViewModel(qrCodesService: codesService, favoritesSerice: generalAssembly.favoritesService)
    }()

    lazy var myCodesViewModel: MyCodesListViewModel = {
        MyCodesListViewModel(qrCodesService: codesService)
    }()
}
