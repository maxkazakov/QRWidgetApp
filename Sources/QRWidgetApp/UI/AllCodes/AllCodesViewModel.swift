import SwiftUI
import XCTestDynamicOverlay

enum SelectedTab: Int {
    case favorites = 0
    case scans = 1
    case my = 2
}

class AllCodesViewModel: ObservableObject {

    enum Destination {
        case newCode(CodeCreationFlowModel)
    }

    init(codesService: QRCodesService, sendAnalytics: @escaping SendAnalyticsAction) {
        self.codesService = codesService
        self.sendAnalytics = sendAnalytics
    }

    @Published var selectedTab: SelectedTab = .scans
    @Published var destination: Destination? {
        didSet {
            self.bind()
        }
    }

    var startScanningTapped: EmptyBlock = unimplemented("AllCodesViewModel.startScanningTapped") {
        didSet {
            historyViewModel.startScanningTapped = startScanningTapped
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
        var model = MyCodesListViewModel(qrCodesService: codesService)
        model.createNewTapped = { [weak self] in self?.createdNewCodeTapped() }
        return model
    }()

    func createdNewCodeTapped() {
        sendAnalytics(.tapCreateNewQR, [:])
        destination = .newCode(CodeCreationFlowModel())
    }

    func bind() {
        switch destination {
        case let .newCode(codeCreationModel):
            codeCreationModel.onCodeCreatoinFinished = { [weak self] newCode in
                guard let self else { return }
                self.codesService.addNew(qrModel: newCode)
                self.destination = nil
            }
        case .none:
            break
        }
    }
}
