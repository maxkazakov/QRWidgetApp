//
//  WidgetsService.swift
//  QRWidget
//
//  Created by Максим Казаков on 20.02.2022.
//

import UIKit
import Combine
import WidgetKit

class WidgetsService {
    private let repository: QRCodesRepository
    private let favoritesService: FavoritesService

    init(repository: QRCodesRepository, favoritesService: FavoritesService) {
        self.repository = repository
        self.favoritesService = favoritesService
    }

    private var cancellableSet = Set<AnyCancellable>()

    // MARK: - Private
    func subscribeQrChanges() {
        repository.qrCodesPublisher
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
