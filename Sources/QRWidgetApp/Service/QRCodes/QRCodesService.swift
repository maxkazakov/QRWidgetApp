
import UIKit
import Combine
import WidgetKit
import QRWidgetCore
import Dependencies

struct CodesService {
    var createNewQrCode: (_ stringPayload: String?, _ descriptor: CIBarcodeDescriptor?, _ type: CodeType, _ batchId: UUID?) -> CodeModel
    var addNewQrCodes: (_ qrModels: [CodeModel]) -> Void
    var changeQRLabel: (_ id: UUID, _ newLabel: String) -> Void
    var changeQRAppearance: (_ id: UUID, _ errorCorrectionLevel: ErrorCorrection, _ foreground: UIColor?, _ background: UIColor?, _ qrStyle: QRStyle?) -> Void
    var updateQR: (_ qrModel: CodeModel) -> Void
    var getQR: (_ id: UUID) -> CodeModel?
    var removeQR: (_ id: UUID) -> Void
    var allQrCodes: () -> [CodeModel]
}

extension CodesService {
    static let live = {
        let _live = generalAssembly.qrCodesService
        return CodesService(
            createNewQrCode: _live.createNewQrCode(stringPayload:descriptor:type:batchId:),
            addNewQrCodes: _live.addNewQrCodes(qrModels:),
            changeQRLabel: _live.changeQRLabel(id:newLabel:),
            changeQRAppearance: _live.changeQRAppearance(id:errorCorrectionLevel:foreground:background:qrStyle:),
            updateQR: _live.updateQR,
            getQR: _live.getQR(id:),
            removeQR: _live.removeQR(id:),
            allQrCodes: {
                _live.qrCodesPublisher.value
            }
        )
    }()
}

extension DependencyValues {
    var codesService: CodesService {
        get { self[CodesServiceKey.self] }
        set { self[CodesServiceKey.self] = newValue }
    }
}

private enum CodesServiceKey: DependencyKey {
    static let liveValue = CodesService.live
}

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
    func createNewQrCode(stringPayload: String?, descriptor: CIBarcodeDescriptor?, type: CodeType, batchId: UUID? = nil) -> CodeModel {
        let data = CodeModel.DataType(stringPayload: stringPayload, descriptor: descriptor)
        let qrCode = CodeModel(data: data, type: type, batchId: batchId, qrStyle: nil)
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

    func changeQRAppearance(id: UUID, errorCorrectionLevel: ErrorCorrection, foreground: UIColor?, background: UIColor?, qrStyle: QRStyle?) {
        guard var qrModel = getQR(id: id) else { return }
        qrModel.errorCorrectionLevel = errorCorrectionLevel
        qrModel.foregroundColor = foreground
        qrModel.backgroundColor = background
        qrModel.qrStyle = qrStyle

        updateQR(qrModel)
    }

    func updateQR(_ qrModel: CodeModel) {
        qrCodesPublisher.value
            .firstIndex { $0.id == qrModel.id }
            .map { qrCodesPublisher.value[$0] = qrModel }
        repository.update(qrModel: qrModel)
    }

    func getQR(id: UUID) -> CodeModel? {
        let codeModel = qrCodesPublisher.value.first { $0.id == id }
        return codeModel
    }

    func removeQR(id: UUID) {
        qrCodesPublisher.value.removeAll { $0.id == id }
        repository.remove(id: id)
        walletService.deletePass(by: id)
        favoritesService.removeFavorite(id: id)
    }
}
