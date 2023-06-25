
import UIKit
import Combine
import WidgetKit
import QRWidgetCore

class QRCodesService {
    private let repository: QRCodesRepository
    private let walletService: WalletService
    private let favoritesService: FavoritesService

    init(repository: QRCodesRepository,
         walletService: WalletService,
         favotitesService: FavoritesService
    ) {
        self.repository = repository
        self.walletService = walletService
        self.favoritesService = favotitesService

        self.qrCodesPublisher = CurrentValueSubject([])
        self.favoriteQrCodes = Publishers.CombineLatest(
            favotitesService.favorites,
            qrCodesPublisher
        )
            .map { (favIds, qrCodes) -> [CodeModel] in
                let favIdsSet = Set(favIds)
                return qrCodes.filter { favIdsSet.contains($0.id) }
            }
            .eraseToAnyPublisher()

        let allCodes = repository.loadAllCodes()
        qrCodesPublisher.send(allCodes)
    }
    
    private var cancellableSet = Set<AnyCancellable>()
    
    let qrCodesPublisher: CurrentValueSubject<[CodeModel], Never>
    let favoriteQrCodes: AnyPublisher<[CodeModel], Never>

    @discardableResult
    func createNewQrCode(data: String, type: CodeType, batchId: UUID? = nil) -> CodeModel {
        let qrCode = CodeModel(data: data, type: type, batchId: batchId)
        addNew(qrModel: qrCode)
        return qrCode
    }
    
    func addNewQrCodes(qrModels: [CodeModel]) {
        for qr in qrModels {
            addNew(qrModel: qr)
        }
    }

    func addNew(qrModel: CodeModel) {
        qrCodesPublisher.value.append(qrModel)
        repository.addNew(qr: qrModel)
    }

    func changeQRLabel(id: UUID, newLabel: String) {
        guard var qrModel = getQR(id: id) else { return }
        qrModel.label = newLabel

        updateQR(qrModel)
    }

    func changeQRAppearance(id: UUID, errorCorrectionLevel: ErrorCorrection, foreground: UIColor?, background: UIColor?) {
        guard var qrModel = getQR(id: id) else { return }
        qrModel.errorCorrectionLevel = errorCorrectionLevel
        qrModel.foregroundColor = foreground
        qrModel.backgroundColor = background

        updateQR(qrModel)
    }

    func updateQR(_ qrModel: CodeModel) {
        qrCodesPublisher.value
            .firstIndex { $0.id == qrModel.id }
            .map { qrCodesPublisher.value[$0] = qrModel }
        repository.update(qrModel: qrModel)
    }

    func getQR(id: UUID) -> CodeModel? {
        qrCodesPublisher.value.first { $0.id == id }
    }

    func removeQR(id: UUID) {
        qrCodesPublisher.value.removeAll { $0.id == id }
        repository.remove(id: id)
        walletService.deletePass(by: id)
        favoritesService.removeFavorite(id: id)
    }
}
