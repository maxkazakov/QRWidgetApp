
import Foundation
import SwiftUI

class SingleCodeRowViewModel: ViewModel {

    private let favoritesService: FavoritesService
    @Published var isFavorite = false

    init(id: UUID, favoritesService: FavoritesService) {
        self.favoritesService = favoritesService
        super.init()

        favoritesService.favorites
            .map { $0.contains(id) }
            .sink(receiveValue: { [weak self] in
                self?.isFavorite = $0
        })
        .store(in: &cancellableSet)
    }
}

