//
//  QRCodesService.swift
//  QRWidget
//
//  Created by Максим Казаков on 14.02.2022.
//

import UIKit
import Combine
import WidgetKit
import QRWidgetCore

class QRCodesService {
    private let repository: QRCodesRepository
    private let walletService: WalletService
    private let userStorage: UserDefaultsStorage
    private let favoritesService: FavoritesService

    init(repository: QRCodesRepository,
         walletService: WalletService,
         userStorage: UserDefaultsStorage,
         favotitesService: FavoritesService
    ) {
        self.repository = repository
        self.walletService = walletService
        self.userStorage = userStorage
        self.favoritesService = favotitesService

        self.selectedQRCodePublisher = CurrentValueSubject<UUID?, Never>(userStorage.selectedQR)
        self.favoriteQrCodes = Publishers.CombineLatest(favotitesService.favorites, repository.qrCodesPublisher)
            .map { (favIds, qrCodes) -> [QRModel] in
                let favIdsSet = Set(favIds)
                let result = qrCodes.filter { favIdsSet.contains($0.id) }
                return result
            }
            .eraseToAnyPublisher()
    }
    
    private var cancellableSet = Set<AnyCancellable>()

    let selectedQRCodePublisher: CurrentValueSubject<UUID?, Never>
    let favoriteQrCodes: AnyPublisher<[QRModel], Never>

    func setSelectedQR(id: UUID) {
        selectedQRCodePublisher.send(id)
        userStorage.selectedQR = id
    }

    @discardableResult
    func createNewQrCode(data: String, batchId: UUID? = nil) -> QRModel {
        let qrCode = QRModel(qrData: data, batchId: batchId)
        repository.addNew(qr: qrCode)
        return qrCode
    }
    
    func createManyQrCodes(qrModels: [QRModel]) {
        for qr in qrModels {
            repository.addNew(qr: qr)
        }
    }

    func changeQRLabel(id: UUID, newLabel: String) {
        guard var qrModel = repository.get(id: id) else {
            return
        }
        qrModel.label = newLabel
        repository.update(qrModel: qrModel)
    }

    func changeQRAppearance(id: UUID, errorCorrectionLevel: ErrorCorrection, foreground: UIColor?, background: UIColor?) {
        guard var qrModel = repository.get(id: id) else {
            return
        }
        qrModel.errorCorrectionLevel = errorCorrectionLevel
        qrModel.foregroundColor = foreground
        qrModel.backgroundColor = background
        repository.update(qrModel: qrModel)
    }

    func getQR(id: UUID) -> QRModel? {
        repository.get(id: id)
    }

    func removeQR(id: UUID) {
        repository.remove(id: id)
        walletService.deletePass(by: id)
        favoritesService.removeFavorite(id: id)
    }

    // MARK: - Private
}
