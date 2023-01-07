
import UIKit
import Combine
import WidgetKit

class WidgetsService {
    private let qrCodesService: QRCodesService
    private let favoritesService: FavoritesService

    init(qrCodesService: QRCodesService, favoritesService: FavoritesService) {
        self.qrCodesService = qrCodesService
        self.favoritesService = favoritesService
    }

    private var cancellableSet = Set<AnyCancellable>()

    // MARK: - Private
    func subscribeQrChanges() {
        qrCodesService.qrCodesPublisher
            .sink(receiveValue: { _ in
                self.reloadWidgets()
            })
            .store(in: &cancellableSet)

        favoritesService.favorites
            .sink(receiveValue: { _ in
                self.reloadWidgets()
            })
            .store(in: &cancellableSet)
    }

    func reloadWidgets() {
        // Need delay to wait for saving on disk
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
