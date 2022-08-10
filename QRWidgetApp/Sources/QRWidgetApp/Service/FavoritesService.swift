//
//  FavoritesService.swift
//  QRWidget
//
//  Created by Максим Казаков on 16.04.2022.
//

import Foundation
import Combine

public class FavoritesService {
    let favorites: CurrentValueSubject<Set<UUID>, Never>
    private let storage = UserDefaultsStorage()
    private var cancellableSet = Set<AnyCancellable>()

    public init() {
        self.favorites = CurrentValueSubject<Set<UUID>, Never>(Set(storage.favoriteIds))
        self.favorites
            .dropFirst()
            .sink(receiveValue: {
                self.storage.favoriteIds = Array($0)
            })
            .store(in: &cancellableSet)
    }

    public func isFavorite(qrId: UUID) -> Bool {
        return favorites.value.contains(qrId)
    }

    func setFavotites(ids: Set<UUID>) {
        favorites.send(ids)
    }

    func addSavorite(id: UUID) {
        var newFavoriteIds = favorites.value
        newFavoriteIds.insert(id)
        favorites.send(newFavoriteIds)
    }

    func removeFavorite(id: UUID) {
        var newFavoriteIds = favorites.value
        newFavoriteIds.remove(id)
        favorites.send(newFavoriteIds)
    }
}
