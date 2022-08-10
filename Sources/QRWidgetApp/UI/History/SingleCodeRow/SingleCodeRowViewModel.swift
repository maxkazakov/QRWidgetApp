//
//  SingleCodeRowViewModel.swift
//  QRWidget
//
//  Created by Максим Казаков on 15.06.2022.
//

import Foundation
import SwiftUI

class SingleCodeRowViewModel: ViewModel {

    private let favoritesService: FavoritesService
    @Published var model: SingleCodeRowUIModel

    init(model: SingleCodeRowUIModel, favoritesService: FavoritesService) {
        self.favoritesService = favoritesService
        self.model = model
        super.init()

        favoritesService.favorites
            .map { $0.contains(model.id) }
            .sink(receiveValue: { [weak self] in
                self?.model.isFavorite = $0
        })
        .store(in: &cancellableSet)
    }
}

