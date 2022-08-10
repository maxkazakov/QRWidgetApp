//
//  MainTabViewModel.swift
//  QRWidget
//
//  Created by Максим Казаков on 21.02.2022.
//

import SwiftUI
import Foundation
import Combine

let selectedTabBarPublisher = CurrentValueSubject<Tab, Never>(.favorites)

class MainTabViewModel: ViewModel {
    let storage: UserDefaultsStorage
    let sendAnalytics: SendAnalyticsAction
    @Published var currentTab: Tab

    init(storage: UserDefaultsStorage, sendAnalytics: @escaping SendAnalyticsAction) {
        self.storage = storage
        self.sendAnalytics = sendAnalytics
        self.currentTab = selectedTabBarPublisher.value
        super.init()

        selectedTabBarPublisher
            .removeDuplicates()
            .sink(receiveValue: { [weak self] in
                self?.currentTab = $0
            })
            .store(in: &cancellableSet)

        $currentTab
            .removeDuplicates()
            .sink(receiveValue: { [weak self] in
                self?.trackTabChange(tab: $0)
                self?.storage.selectedTab = $0.rawValue
                selectedTabBarPublisher.send($0)
            })
            .store(in: &cancellableSet)
    }

    private func trackTabChange(tab: Tab) {
        switch tab {
        case .favorites:
            sendAnalytics(.openFavoritesTab, nil)
        case .scan:
            sendAnalytics(.openScanTab, nil)
        case .history:
            sendAnalytics(.openHistoryTab, nil)
        case .settings:
            sendAnalytics(.openSettingsTab, nil)
        }
    }
}

