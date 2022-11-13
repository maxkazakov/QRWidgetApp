//
//  FavoritesService.swift
//  QRWidget
//
//  Created by Максим Казаков on 16.04.2022.
//

import Foundation
import Combine

public class FavoritesService {
    let favorites: CurrentValueSubject<[UUID], Never>
    private let storage = UserDefaultsStorage()
    private var cancellableSet = Set<AnyCancellable>()

    public init() {
        self.favorites = CurrentValueSubject<[UUID], Never>(storage.favoriteIds)
        self.favorites
            .dropFirst()
            .sink(receiveValue: {
                self.storage.favoriteIds = $0
            })
            .store(in: &cancellableSet)
    }

    public func isFavorite(qrId: UUID) -> Bool {
        return favorites.value.contains(qrId)
    }

    func setFavotites(ids: [UUID]) {
        favorites.send(ids)
    }

    func addSavorite(id: UUID) {
        var newFavoriteIds = favorites.value
        newFavoriteIds.append(id)
        favorites.send(newFavoriteIds)
    }

    func removeFavorite(id: UUID) {
        var newFavoriteIds = favorites.value
        newFavoriteIds.removeAll { $0 == id }
        favorites.send(newFavoriteIds)
    }
}
