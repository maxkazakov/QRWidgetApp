import SwiftUI
import CodeCreation

enum SelectedTab: Int {
    case favorites = 0
    case history = 1
    case my = 2
}

class AllCodesViewModel: ObservableObject {

    enum Destination {
        case newCode(CodeCreationFlowModel)
    }

    init(
        codesService: QRCodesService,
        historyViewModel: HistoryViewModel,
        favoritesViewModel: FavoritesViewModel,
        myCodesViewModel: MyCodesListViewModel
    ) {
        self.codesService = codesService
        self.historyViewModel = historyViewModel
        self.favoritesViewModel = favoritesViewModel
        self.myCodesViewModel = myCodesViewModel
    }

    @Published var selectedTab: SelectedTab = .history
    @Published var destination: Destination? {
        didSet {
            self.bind()
        }
    }

    let codesService: QRCodesService
    let historyViewModel: HistoryViewModel
    let favoritesViewModel: FavoritesViewModel
    let myCodesViewModel: MyCodesListViewModel

    func createdNewCodeTapped() {
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
