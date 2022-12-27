import SwiftUI
import CodeCreation

enum SelectedTab: Int {
    case favorites = 0
    case history = 1
}

class AllCodesViewModel: ObservableObject {

    enum Destination {
        case newCode(SelectingCodeTypeModel)
    }

    init(
        qrCodeRepo: QRCodesRepository,
        historyViewModel: HistoryViewModel,
        favoritesViewModel: FavoritesViewModel
    ) {
        self.qrCodeRepo = qrCodeRepo
        self.historyViewModel = historyViewModel
        self.favoritesViewModel = favoritesViewModel
    }

    @Published var selectedTab: SelectedTab = .history
    @Published var destination: Destination? {
        didSet {
            self.bind()
        }
    }

    let qrCodeRepo: QRCodesRepository
    let historyViewModel: HistoryViewModel
    let favoritesViewModel: FavoritesViewModel

    func createdNewCodeTapped() {
        destination = .newCode(SelectingCodeTypeModel())
    }

    func bind() {
        switch destination {
        case let .newCode(codeCreationModel):
            codeCreationModel.onCodeCreatoinFinished = { [weak self] newCode in
                guard let self else { return }
                self.qrCodeRepo.addNew(qr: newCode)
                self.destination = nil
            }
        case .none:
            break
        }
    }
}
